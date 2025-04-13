<template>
  <div class="system-params-container">

    <el-card class="config-card">
      <template #header>
        <div class="card-header">
          <h3>系统配置参数</h3>
          <el-button type="primary" size="small" @click="refreshConfigs">刷新</el-button>
        </div>
      </template>
      
      <el-table v-loading="loading.configs" :data="configList" style="width: 100%" border>
        <el-table-column prop="description" label="描述" width="250" />
        <el-table-column prop="config_value" label="配置值" />
        <el-table-column prop="updated_at" label="更新时间" width="180" />
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button size="small" @click="handleEditConfig(scope.row)">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-card class="version-card">
      <template #header>
        <div class="card-header">
          <h3>系统版本信息</h3>
          <el-button type="primary" size="small" @click="refreshVersions">刷新</el-button>
        </div>
      </template>
      
      <el-table v-loading="loading.versions" :data="versionList" style="width: 100%" border>
        <el-table-column prop="version_id" label="ID" width="80" />
        <el-table-column prop="version_number" label="版本号" width="120" />
        <el-table-column prop="knowledge_base_version" label="知识库版本" width="120" />
        <el-table-column prop="release_date" label="发布日期" width="120" />
        <el-table-column prop="update_notes" label="更新说明" />
        <el-table-column label="当前版本" width="120">
          <template #default="scope">
            <el-tag v-if="scope.row.is_current" type="success">当前版本</el-tag>
            <el-tag v-else type="info">历史版本</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button 
              size="small" 
              :disabled="scope.row.is_current" 
              @click="setAsCurrentVersion(scope.row)"
            >
              设为当前版本
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加新版本的按钮 -->
    <div class="action-bar">
      <el-button type="primary" @click="showAddVersionDialog">添加新版本</el-button>
    </div>

    <!-- 编辑配置对话框 -->
    <el-dialog v-model="dialogs.editConfig" title="编辑系统配置" width="500px">
      <el-form :model="currentConfig" label-width="120px">
        <el-form-item label="配置键名">
          <el-input v-model="currentConfig.config_key" disabled />
        </el-form-item>
        <el-form-item label="配置值">
          <el-input v-model="currentConfig.config_value" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="currentConfig.description" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogs.editConfig = false">取消</el-button>
          <el-button type="primary" @click="saveConfigChanges">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 添加新版本对话框 -->
    <el-dialog v-model="dialogs.addVersion" title="添加新版本" width="500px">
      <el-form :model="newVersion" label-width="120px">
        <el-form-item label="版本号" required>
          <el-input v-model="newVersion.version_number" placeholder="例如: 1.0.1" />
        </el-form-item>
        <el-form-item label="知识库版本">
          <el-input v-model="newVersion.knowledge_base_version" placeholder="例如: v3.2.2" />
        </el-form-item>
        <el-form-item label="发布日期" required>
          <el-date-picker v-model="newVersion.release_date" type="date" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="更新说明">
          <el-input v-model="newVersion.update_notes" type="textarea" rows="4" />
        </el-form-item>
        <el-form-item label="设为当前版本">
          <el-switch v-model="newVersion.is_current" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogs.addVersion = false">取消</el-button>
          <el-button type="primary" @click="saveNewVersion">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import axios from 'axios';
import { API_BASE_URL } from '../../../config';

// 加载状态
const loading = reactive({
  configs: false,
  versions: false
});

// 数据列表
const configList = ref([]);
const versionList = ref([]);

// 对话框控制
const dialogs = reactive({
  editConfig: false,
  addVersion: false
});

// 当前编辑的配置
const currentConfig = ref({});

// 新版本表单
const newVersion = ref({
  version_number: '',
  knowledge_base_version: '',
  release_date: new Date(),
  update_notes: '',
  is_current: false
});

// 获取管理员ID
const getAdminId = () => {
  // 从localStorage或其他存储方式获取管理员ID
  const adminId = localStorage.getItem('adminId') || localStorage.getItem('userId');
  return adminId ? parseInt(adminId) : 1; // 默认返回1，根据实际情况调整
};

// 载入系统配置
const loadConfigs = async () => {
  loading.configs = true;
  try {
    const adminId = getAdminId();
    const response = await axios.get(`${API_BASE_URL}/admin/settings/system-configs`, {
      params: { admin_id: adminId }
    });
    if (response.data.code === 200) {
      configList.value = response.data.data;
    } else {
      ElMessage.error(response.data.message || '加载系统配置失败');
    }
  } catch (error) {
    console.error('加载系统配置失败', error);
    ElMessage.error('加载系统配置失败');
  } finally {
    loading.configs = false;
  }
};

// 载入系统版本
const loadVersions = async () => {
  loading.versions = true;
  try {
    const adminId = getAdminId();
    const response = await axios.get(`${API_BASE_URL}/admin/settings/system-versions`, {
      params: { admin_id: adminId }
    });
    if (response.data.code === 200) {
      versionList.value = response.data.data;
    } else {
      ElMessage.error(response.data.message || '加载系统版本失败');
    }
  } catch (error) {
    console.error('加载系统版本失败', error);
    ElMessage.error('加载系统版本失败');
  } finally {
    loading.versions = false;
  }
};

// 刷新配置列表
const refreshConfigs = () => {
  loadConfigs();
};

// 刷新版本列表
const refreshVersions = () => {
  loadVersions();
};

// 处理编辑配置
const handleEditConfig = (config) => {
  currentConfig.value = { ...config };
  dialogs.editConfig = true;
};

// 保存配置更改
const saveConfigChanges = async () => {
  try {
    const adminId = getAdminId();
    const payload = {
      config_value: currentConfig.value.config_value,
      description: currentConfig.value.description,
      admin_id: adminId
    };
    
    const response = await axios.put(`${API_BASE_URL}/admin/settings/system-configs/${currentConfig.value.config_id}`, payload);
    
    if (response.data.code === 200) {
      ElMessage.success('配置已更新');
      dialogs.editConfig = false;
      
      // 刷新配置列表
      loadConfigs();
    } else {
      ElMessage.error(response.data.message || '保存配置失败');
    }
  } catch (error) {
    console.error('保存配置失败', error);
    ElMessage.error('保存配置失败');
  }
};

// 设置当前版本
const setAsCurrentVersion = async (version) => {
  try {
    ElMessageBox.confirm(
      `确定要将版本 ${version.version_number} 设置为当前版本吗？`,
      '确认操作',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    ).then(async () => {
      const adminId = getAdminId();
      const response = await axios.put(`${API_BASE_URL}/admin/settings/system-versions/${version.version_id}/set-current`, {
        admin_id: adminId
      });
      
      if (response.data.code === 200) {
        ElMessage.success('当前版本已更新');
        // 刷新版本列表
        loadVersions();
      } else {
        ElMessage.error(response.data.message || '设置当前版本失败');
      }
    }).catch(() => {
      // 用户取消操作
    });
  } catch (error) {
    console.error('设置当前版本失败', error);
    ElMessage.error('设置当前版本失败');
  }
};

// 显示添加版本对话框
const showAddVersionDialog = () => {
  newVersion.value = {
    version_number: '',
    knowledge_base_version: '',
    release_date: new Date(),
    update_notes: '',
    is_current: false
  };
  dialogs.addVersion = true;
};

// 保存新版本
const saveNewVersion = async () => {
  if (!newVersion.value.version_number || !newVersion.value.release_date) {
    ElMessage.warning('请填写必填字段');
    return;
  }
  
  try {
    // 格式化日期
    const formattedDate = newVersion.value.release_date instanceof Date 
      ? newVersion.value.release_date.toISOString().split('T')[0]
      : newVersion.value.release_date;
    
    const adminId = getAdminId();
    const payload = {
      version_number: newVersion.value.version_number,
      knowledge_base_version: newVersion.value.knowledge_base_version,
      release_date: formattedDate,
      update_notes: newVersion.value.update_notes,
      is_current: newVersion.value.is_current,
      admin_id: adminId
    };
    
    const response = await axios.post(`${API_BASE_URL}/admin/settings/system-versions`, payload);
    
    if (response.data.code === 200) {
      ElMessage.success('新版本已添加');
      dialogs.addVersion = false;
      
      // 刷新版本列表
      loadVersions();
    } else {
      ElMessage.error(response.data.message || '保存新版本失败');
    }
  } catch (error) {
    console.error('保存新版本失败', error);
    ElMessage.error('保存新版本失败');
  }
};

// 初始化
onMounted(() => {
  loadConfigs();
  loadVersions();
});
</script>

<style scoped>
.system-params-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.config-card,
.version-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
}

.action-bar {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

:deep(.el-dialog__body) {
  padding-top: 10px;
}

:deep(.el-table .cell) {
  word-break: break-word;
}

.config-edit-container {
  padding: 20px;
}

.config-info-alert {
  margin-bottom: 20px;
}

.alert-title {
  display: flex;
  align-items: center;
}

.alert-title .el-icon {
  margin-right: 8px;
}

.config-form {
  width: 100%;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  padding-top: 20px;
}

:deep(.el-input-number) {
  width: 100%;
}

:deep(.el-date-editor) {
  width: 100% !important;
}

:deep(.el-divider__text) {
  font-weight: bold;
  color: var(--el-color-primary);
}

/* 移除按钮点击时的黑色边框 */
:deep(.el-button) {
  outline: none !important;
}

:deep(.el-button:focus),
:deep(.el-button:active) {
  outline: none !important;
  border-color: transparent;
  box-shadow: none !important;
}

:deep(.el-button.is-circle:focus),
:deep(.el-button.is-circle:active) {
  outline: none !important;
  border-color: var(--el-button-hover-border-color);
}

/* 为圆形按钮保持悬浮时的边框颜色 */
:deep(.el-button.is-circle.el-button--primary:focus),
:deep(.el-button.is-circle.el-button--primary:active) {
  border-color: var(--el-button-hover-bg-color);
}
</style>