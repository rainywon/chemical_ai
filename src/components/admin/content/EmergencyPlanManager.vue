<template>
  <div class="emergency-plan-manager">
    <div class="page-header">
    <h1>应急处理方案管理</h1>
      <el-button type="primary" @click="handleAddPlan">
        <el-icon><Plus /></el-icon>添加应急方案
      </el-button>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="方案标题">
          <el-input v-model="searchForm.title" placeholder="请输入方案标题"></el-input>
        </el-form-item>
        <el-form-item label="方案类型">
          <el-select v-model="searchForm.plan_type" placeholder="请选择类型" clearable>
            <el-option label="全部" value=""></el-option>
            <el-option label="火灾" value="fire"></el-option>
            <el-option label="泄漏" value="leak"></el-option>
            <el-option label="中毒" value="poison"></el-option>
            <el-option label="其他" value="other"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="发布状态">
          <el-select v-model="searchForm.is_published" placeholder="请选择状态" clearable>
            <el-option label="全部" value=""></el-option>
            <el-option label="已发布" :value="1"></el-option>
            <el-option label="未发布" :value="0"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearchForm">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 应急预案列表 -->
    <div class="plan-list">
      <el-table 
        :data="planList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="plan_id" label="方案ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="title" label="方案标题" min-width="200" align="left" :show-overflow-tooltip="true"></el-table-column>
        <el-table-column prop="plan_type" label="类型" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="getPlanTypeTag(scope.row.plan_type)" effect="dark">
              {{ getPlanTypeLabel(scope.row.plan_type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_published" label="状态" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_published === 1 ? 'success' : 'info'">
              {{ scope.row.is_published === 1 ? '已发布' : '未发布' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" min-width="160" align="center"></el-table-column>
        <el-table-column prop="updated_at" label="更新时间" min-width="160" align="center"></el-table-column>
        <el-table-column label="操作" min-width="180" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button 
              size="small" 
              :type="scope.row.is_published === 1 ? 'warning' : 'success'"
              @click="handleTogglePublish(scope.row)">
              {{ scope.row.is_published === 1 ? '取消发布' : '发布' }}
            </el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :current-page="currentPage"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </div>

    <!-- 添加/编辑应急方案对话框 -->
    <el-dialog 
      :title="dialogType === 'add' ? '添加应急方案' : '编辑应急方案'" 
      v-model="dialogVisible" 
      width="700px"
      :close-on-click-modal="false">
      <el-form 
        ref="planFormRef"
        :model="planForm" 
        :rules="planRules"
        label-width="100px">
        <el-form-item label="方案标题" prop="title">
          <el-input v-model="planForm.title" placeholder="请输入方案标题"></el-input>
        </el-form-item>
        <el-form-item label="方案类型" prop="plan_type">
          <el-select 
            v-model="planForm.plan_type" 
            placeholder="请选择类型"
            style="width: 100%">
            <el-option label="火灾" value="fire"></el-option>
            <el-option label="泄漏" value="leak"></el-option>
            <el-option label="中毒" value="poison"></el-option>
            <el-option label="其他" value="other"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="方案内容" prop="content">
          <el-input 
            v-model="planForm.content" 
            type="textarea" 
            :rows="10" 
            placeholder="请输入应急方案内容">
          </el-input>
        </el-form-item>
        <el-form-item label="是否发布" prop="is_published">
          <el-switch 
            v-model="planForm.is_published"
            :active-value="1"
            :inactive-value="0">
          </el-switch>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmitPlan" :loading="submitLoading">确认</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 预览方案对话框 -->
    <el-dialog 
      title="应急方案预览" 
      v-model="previewDialogVisible" 
      width="800px">
      <div v-if="currentPlan" class="plan-preview">
        <h2 class="plan-preview-title">{{ currentPlan.title }}</h2>
        <div class="plan-preview-meta">
          <el-tag :type="getPlanTypeTag(currentPlan.plan_type)" effect="dark" class="plan-type-tag">
            {{ getPlanTypeLabel(currentPlan.plan_type) }}
          </el-tag>
          <span class="plan-update-time">更新时间: {{ currentPlan.updated_at }}</span>
        </div>
        <div class="plan-preview-content">
          <p v-for="(paragraph, index) in getContentParagraphs(currentPlan.content)" :key="index">
            {{ paragraph }}
          </p>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const submitLoading = ref(false);
const planList = ref([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const dialogVisible = ref(false);
const previewDialogVisible = ref(false);
const dialogType = ref('add'); // 对话框类型：'add'新增，'edit'编辑
const currentPlan = ref(null);
const currentPlanId = ref(null);

// 搜索表单
const searchForm = reactive({
  title: '',
  plan_type: '',
  is_published: ''
});

// 应急方案表单
const planFormRef = ref(null);
const planForm = reactive({
  title: '',
  plan_type: 'fire',
  content: '',
  is_published: 1
});

// 表单验证规则
const planRules = {
  title: [
    { required: true, message: '请输入方案标题', trigger: 'blur' },
    { max: 100, message: '方案标题不能超过100个字符', trigger: 'blur' }
  ],
  plan_type: [
    { required: true, message: '请选择方案类型', trigger: 'change' }
  ],
  content: [
    { required: true, message: '请输入方案内容', trigger: 'blur' }
  ]
};

// 初始化
onMounted(() => {
  fetchPlanList();
});

// 获取应急方案列表
const fetchPlanList = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value);
    params.append('page_size', pageSize.value);
    
    if (searchForm.title) {
      params.append('title', searchForm.title);
    }
    
    if (searchForm.plan_type) {
      params.append('plan_type', searchForm.plan_type);
    }
    
    if (searchForm.is_published !== '') {
      params.append('is_published', searchForm.is_published);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/content/emergency-plans?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      planList.value = data.data.plans;
      total.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取应急方案列表失败');
    }
  } catch (error) {
    console.error('获取应急方案列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 获取方案类型标签样式
const getPlanTypeTag = (type) => {
  const typeMap = {
    'fire': 'danger',
    'leak': 'warning',
    'poison': 'info',
    'other': ''
  };
  return typeMap[type] || '';
};

// 获取方案类型标签文字
const getPlanTypeLabel = (type) => {
  const labelMap = {
    'fire': '火灾',
    'leak': '泄漏',
    'poison': '中毒',
    'other': '其他'
  };
  return labelMap[type] || type;
};

// 将内容字符串分割为段落
const getContentParagraphs = (content) => {
  if (!content) return [];
  return content.split('\n').filter(p => p.trim());
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  fetchPlanList();
};

// 重置搜索表单
const resetSearchForm = () => {
  searchForm.title = '';
  searchForm.plan_type = '';
  searchForm.is_published = '';
  currentPage.value = 1;
  fetchPlanList();
};

// 分页大小改变
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchPlanList();
};

// 当前页码改变
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchPlanList();
};

// 重置方案表单
const resetPlanForm = () => {
  if (planFormRef.value) {
    planFormRef.value.resetFields();
  }
  planForm.title = '';
  planForm.plan_type = 'fire';
  planForm.content = '';
  planForm.is_published = 1;
};

// 打开添加方案对话框
const handleAddPlan = () => {
  dialogType.value = 'add';
  resetPlanForm();
  dialogVisible.value = true;
};

// 打开编辑方案对话框
const handleEdit = (row) => {
  dialogType.value = 'edit';
  currentPlanId.value = row.plan_id;
  
  // 填充表单数据
  planForm.title = row.title;
  planForm.plan_type = row.plan_type;
  planForm.content = row.content;
  planForm.is_published = row.is_published;
  
  dialogVisible.value = true;
};

// 处理方案表单提交
const handleSubmitPlan = async () => {
  if (!planFormRef.value) return;
  
  await planFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    submitLoading.value = true;
    try {
      const url = dialogType.value === 'add' 
        ? `${API_BASE_URL}/admin/content/emergency-plans` 
        : `${API_BASE_URL}/admin/content/emergency-plans/${currentPlanId.value}`;
      
      const method = dialogType.value === 'add' ? 'POST' : 'PUT';
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          ...planForm,
          admin_id: localStorage.getItem('admin_id')
        })
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success(dialogType.value === 'add' ? '添加方案成功' : '更新方案成功');
        dialogVisible.value = false;
        fetchPlanList(); // 刷新列表
      } else {
        ElMessage.error(data.message || (dialogType.value === 'add' ? '添加方案失败' : '更新方案失败'));
      }
    } catch (error) {
      console.error(dialogType.value === 'add' ? '添加方案错误:' : '更新方案错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    } finally {
      submitLoading.value = false;
    }
  });
};

// 处理切换发布状态
const handleTogglePublish = async (row) => {
  const action = row.is_published === 1 ? '取消发布' : '发布';
  const newStatus = row.is_published === 1 ? 0 : 1;
  
  ElMessageBox.confirm(
    `确定要${action}方案 "${row.title}" 吗？`,
    `${action}确认`,
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: row.is_published === 1 ? 'warning' : 'success'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/emergency-plans/${row.plan_id}/status`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          is_published: newStatus,
          admin_id: localStorage.getItem('admin_id')
        })
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success(`${action}成功`);
        fetchPlanList(); // 刷新列表
      } else {
        ElMessage.error(data.message || `${action}失败`);
      }
    } catch (error) {
      console.error(`${action}错误:`, error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 取消操作，不做处理
  });
};

// 处理删除方案
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `确定要删除方案 "${row.title}" 吗？删除后将无法恢复。`,
    '删除确认',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/emergency-plans/${row.plan_id}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          admin_id: localStorage.getItem('admin_id')
        })
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success('删除方案成功');
        fetchPlanList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '删除方案失败');
      }
    } catch (error) {
      console.error('删除方案错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 取消删除，不做操作
  });
};

// 打开预览方案对话框
const handlePreview = (row) => {
  currentPlan.value = { ...row };
  previewDialogVisible.value = true;
};
</script>

<style scoped>
.emergency-plan-manager {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.search-container {
  margin-bottom: 20px;
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 4px;
}

.plan-list {
  margin-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.plan-preview {
  padding: 10px;
}

.plan-preview-title {
  text-align: center;
  margin-bottom: 20px;
  font-size: 22px;
}

.plan-preview-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ebeef5;
}

.plan-type-tag {
  font-size: 14px;
}

.plan-update-time {
  color: #999;
  font-size: 14px;
}

.plan-preview-content {
  line-height: 1.8;
  font-size: 16px;
}

:deep(.el-dialog__body) {
  padding-top: 10px;
}
</style> 