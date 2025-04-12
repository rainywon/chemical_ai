<template>
  <div class="role-permission-container">
    <h1 class="page-title">角色权限管理</h1>
    
    <!-- 角色切换卡片 -->
    <div class="role-switch-container">
      <el-card>
        <div class="role-switch-header">
          <h2>选择角色</h2>
          <div class="role-tabs">
            <el-radio-group v-model="currentRole" @change="handleRoleChange">
              <el-radio-button label="admin">超级管理员</el-radio-button>
              <el-radio-button label="operator">操作员</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </el-card>
    </div>
    
    <!-- 权限设置区域 -->
    <div class="permission-container" v-loading="loading">
      <el-card>
        <template #header>
          <div class="permission-header">
            <h2>{{ currentRole === 'admin' ? '超级管理员' : '操作员' }}权限设置</h2>
            <div class="actions">
              <el-button type="primary" @click="savePermissions" :loading="saving">
                保存设置
              </el-button>
            </div>
          </div>
        </template>
        
        <div class="permission-content">
          <p class="role-description">
            {{ currentRole === 'admin' ? '超级管理员拥有系统的全部权限，可以管理其他管理员账号及系统配置。' : '操作员拥有系统的部分权限，主要处理日常事务。' }}
          </p>
          
          <el-alert
            v-if="currentRole === 'admin'"
            type="warning"
            :closable="false"
            show-icon
          >
            <strong>超级管理员默认拥有所有权限且不可修改，修改此设置仅对新建超级管理员生效。</strong>
          </el-alert>
          
          <div class="permission-tree-container">
            <el-tree
              ref="permissionTree"
              :data="permissionTree"
              show-checkbox
              node-key="id"
              :default-checked-keys="checkedPermissions"
              :props="defaultProps"
              :disabled="currentRole === 'admin'"
            >
            </el-tree>
          </div>
        </div>
      </el-card>
    </div>
    
    <!-- 角色说明区域 -->
    <div class="role-description-container">
      <el-card>
        <template #header>
          <div class="role-description-header">
            <h2>角色说明</h2>
          </div>
        </template>
        
        <div class="role-description-content">
          <el-descriptions border :column="1">
            <el-descriptions-item label="超级管理员">
              <el-tag type="danger">超级管理员</el-tag>
              <div class="description-text">
                拥有系统的全部权限，包括管理其他管理员、修改系统配置等高级功能。
              </div>
            </el-descriptions-item>
            <el-descriptions-item label="操作员">
              <el-tag type="success">操作员</el-tag>
              <div class="description-text">
                拥有系统的部分权限，只能处理日常事务，不能管理其他管理员和系统配置。
              </div>
            </el-descriptions-item>
          </el-descriptions>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const saving = ref(false);
const currentRole = ref('operator');
const permissionTree = ref([]);
const checkedPermissions = ref([]);
const permissionTree = ref(null);

// API基础URL，确保没有尾斜杠
const apiBaseUrl = computed(() => {
  if (API_BASE_URL.endsWith('/')) {
    return API_BASE_URL.slice(0, -1);
  }
  return API_BASE_URL;
});

// 树形控件配置
const defaultProps = {
  children: 'children',
  label: 'label'
};

// 初始化权限树
const initPermissionTree = () => {
  permissionTree.value = [
    {
      id: 'system',
      label: '系统管理',
      children: [
        { id: 'system:config', label: '系统配置' },
        { id: 'system:version', label: '版本管理' }
      ]
    },
    {
      id: 'admin',
      label: '管理员管理',
      children: [
        { id: 'admin:list', label: '管理员列表' },
        { id: 'admin:add', label: '添加管理员' },
        { id: 'admin:edit', label: '编辑管理员' },
        { id: 'admin:delete', label: '删除管理员' },
        { id: 'admin:status', label: '修改管理员状态' }
      ]
    },
    {
      id: 'user',
      label: '用户管理',
      children: [
        { id: 'user:list', label: '用户列表' },
        { id: 'user:view', label: '查看用户详情' },
        { id: 'user:status', label: '修改用户状态' },
        { id: 'user:history', label: '查看登录历史' }
      ]
    },
    {
      id: 'content',
      label: '内容管理',
      children: [
        { id: 'content:category', label: '分类管理' },
        { id: 'content:document', label: '文档管理' },
        { id: 'content:emergency', label: '应急预案管理' }
      ]
    },
    {
      id: 'log',
      label: '日志管理',
      children: [
        { id: 'log:operation', label: '操作日志' },
        { id: 'log:login', label: '登录日志' }
      ]
    },
    {
      id: 'feedback',
      label: '反馈管理',
      children: [
        { id: 'feedback:list', label: '反馈列表' },
        { id: 'feedback:reply', label: '回复反馈' }
      ]
    }
  ];
};

// 获取角色权限
const fetchRolePermissions = async () => {
  loading.value = true;
  try {
    const adminId = localStorage.getItem('admin_id');
    
    const response = await fetch(`${apiBaseUrl.value}/admin/roles/${currentRole.value}/permissions?admin_id=${adminId || ''}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      }
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API请求失败: ${response.status} ${errorText}`);
    }
    
    const data = await response.json();
    
    if (data.code === 200) {
      // 如果是超级管理员，默认选中所有权限
      if (currentRole.value === 'admin') {
        checkedPermissions.value = getAllPermissionIds();
      } else {
        checkedPermissions.value = data.data.permissions || [];
      }
    } else {
      ElMessage.error(data.message || '获取角色权限失败');
    }
  } catch (error) {
    console.error('获取角色权限失败:', error);
    ElMessage.error('网络连接异常，请稍后再试');
    // 如果是超级管理员，设置所有权限
    if (currentRole.value === 'admin') {
      checkedPermissions.value = getAllPermissionIds();
    }
  } finally {
    loading.value = false;
  }
};

// 获取所有权限ID
const getAllPermissionIds = () => {
  const allIds = [];
  
  const traverseTree = (nodes) => {
    nodes.forEach(node => {
      allIds.push(node.id);
      if (node.children && node.children.length > 0) {
        traverseTree(node.children);
      }
    });
  };
  
  traverseTree(permissionTree.value);
  return allIds;
};

// 处理角色变更
const handleRoleChange = () => {
  fetchRolePermissions();
};

// 保存权限设置
const savePermissions = async () => {
  if (currentRole.value === 'admin') {
    ElMessageBox.alert('超级管理员默认拥有所有权限且不可修改', '提示', {
      confirmButtonText: '我知道了',
      type: 'info'
    });
    return;
  }
  
  saving.value = true;
  try {
    const checkedNodes = permissionTree.value.getCheckedNodes(false, true);
    const halfCheckedNodes = permissionTree.value.getHalfCheckedNodes();
    
    const permissions = [
      ...checkedNodes.map(node => node.id),
      ...halfCheckedNodes.map(node => node.id)
    ];
    
    const adminId = localStorage.getItem('admin_id');
    
    const response = await fetch(`${apiBaseUrl.value}/admin/roles/${currentRole.value}/permissions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      },
      body: JSON.stringify({
        permissions,
        admin_id: adminId ? parseInt(adminId) : null
      })
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API请求失败: ${response.status} ${errorText}`);
    }
    
    const data = await response.json();
    
    if (data.code === 200) {
      ElMessage.success('权限设置保存成功');
    } else {
      ElMessage.error(data.message || '权限设置保存失败');
    }
  } catch (error) {
    console.error('权限设置保存失败:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    saving.value = false;
  }
};

// 生命周期钩子
onMounted(() => {
  // 检查管理员身份
  const isAdmin = localStorage.getItem('isAdmin') === 'true';
  const role = localStorage.getItem('admin_role');
  
  if (!isAdmin) {
    ElMessage.error('只有管理员才能访问此页面');
    return;
  }
  
  if (role !== 'admin') {
    ElMessage.warning('只有超级管理员才能修改角色权限设置');
  }
  
  // 初始化权限树
  initPermissionTree();
  
  // 加载角色权限
  fetchRolePermissions();
});
</script>

<style scoped>
.role-permission-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 24px;
  font-size: 24px;
  font-weight: 500;
  color: #333;
}

.role-switch-container,
.permission-container,
.role-description-container {
  margin-bottom: 20px;
}

.role-switch-header,
.permission-header,
.role-description-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.role-switch-header h2,
.permission-header h2,
.role-description-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 500;
}

.permission-content {
  padding: 10px 0;
}

.role-description {
  margin-bottom: 20px;
  color: #606266;
  line-height: 1.6;
}

.permission-tree-container {
  margin-top: 20px;
  padding: 10px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.description-text {
  margin-top: 8px;
  color: #606266;
  line-height: 1.6;
}

:deep(.el-alert__title) {
  font-size: 14px;
}

:deep(.el-descriptions__label) {
  width: 120px;
}

:deep(.el-button:focus),
:deep(.el-button:focus-visible) {
  outline: none !important;
  box-shadow: none !important;
  border-color: initial;
}
</style> 