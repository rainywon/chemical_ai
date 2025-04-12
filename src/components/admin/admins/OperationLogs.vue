<template>
  <div class="operation-logs-container">
    <h1 class="page-title">操作日志</h1>
    
    <!-- 搜索过滤区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchParams" class="search-form">
        <el-form-item label="操作人ID">
          <el-input v-model="searchParams.adminId" placeholder="请输入管理员ID" clearable></el-input>
        </el-form-item>
        <el-form-item label="操作类型">
          <el-select v-model="searchParams.operationType" placeholder="请选择操作类型" clearable>
            <el-option value="login" label="登录"></el-option>
            <el-option value="logout" label="登出"></el-option>
            <el-option value="query" label="查询"></el-option>
            <el-option value="create" label="创建"></el-option>
            <el-option value="update" label="更新"></el-option>
            <el-option value="delete" label="删除"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            clearable
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchLogs">
            <i class="el-icon-search"></i> 搜索
          </el-button>
          <el-button @click="resetSearchParams">
            <i class="el-icon-refresh"></i> 重置
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 操作日志表格 -->
    <div class="table-container">
      <el-table
        :data="operationLogs"
        border
        stripe
        style="width: 100%"
        v-loading="loading"
        :header-cell-style="{background:'#f5f7fa', color:'#606266', fontWeight: 'bold'}"
        :cell-style="{ padding: '12px 8px' }"
      >
        <el-table-column prop="log_id" label="日志ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="admin_id" label="管理员ID" min-width="100" align="center"></el-table-column>
        <el-table-column prop="operation_type" label="操作类型" min-width="120" align="center">
          <template #default="scope">
            <el-tag :type="getOperationTypeTag(scope.row.operation_type)">
              {{ scope.row.operation_type }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="operation_desc" label="操作描述" min-width="300" align="left">
          <template #default="scope">
            <el-tooltip
              effect="dark"
              :content="scope.row.operation_desc"
              placement="top"
              :hide-after="3000"
              v-if="scope.row.operation_desc && scope.row.operation_desc.length > 50"
            >
              <div class="operation-desc">{{ scope.row.operation_desc.slice(0, 50) }}...</div>
            </el-tooltip>
            <div v-else class="operation-desc">{{ scope.row.operation_desc }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="ip_address" label="IP地址" min-width="130" align="center"></el-table-column>
        <el-table-column prop="created_at" label="操作时间" min-width="160" align="center"></el-table-column>
        <el-table-column label="详情" width="80" align="center">
          <template #default="scope">
            <el-button
              size="small"
              type="primary"
              @click="showLogDetail(scope.row)"
            >
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="totalItems"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :current-page="currentPage"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </div>

    <!-- 日志详情对话框 -->
    <el-dialog 
      title="日志详情" 
      v-model="detailDialogVisible" 
      width="600px" 
      :close-on-click-modal="false"
    >
      <div v-if="selectedLog" class="log-detail">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="日志ID">{{ selectedLog.log_id }}</el-descriptions-item>
          <el-descriptions-item label="管理员ID">{{ selectedLog.admin_id }}</el-descriptions-item>
          <el-descriptions-item label="操作类型">
            <el-tag :type="getOperationTypeTag(selectedLog.operation_type)">
              {{ selectedLog.operation_type }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="操作描述">{{ selectedLog.operation_desc }}</el-descriptions-item>
          <el-descriptions-item label="IP地址">{{ selectedLog.ip_address }}</el-descriptions-item>
          <el-descriptions-item label="用户代理">{{ selectedLog.user_agent || '未记录' }}</el-descriptions-item>
          <el-descriptions-item label="操作时间">{{ selectedLog.created_at }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue';
import { ElMessage } from 'element-plus';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const operationLogs = ref([]);
const totalItems = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);
const detailDialogVisible = ref(false);
const selectedLog = ref(null);
const dateRange = ref([]);

// API基础URL，确保没有尾斜杠
const apiBaseUrl = computed(() => {
  if (API_BASE_URL.endsWith('/')) {
    return API_BASE_URL.slice(0, -1);
  }
  return API_BASE_URL;
});

// 搜索参数
const searchParams = reactive({
  adminId: '',
  operationType: '',
  startDate: '',
  endDate: ''
});

// 监听日期范围变化，更新搜索参数
watch(dateRange, (newValue) => {
  if (newValue && newValue.length === 2) {
    searchParams.startDate = newValue[0];
    searchParams.endDate = newValue[1];
  } else {
    searchParams.startDate = '';
    searchParams.endDate = '';
  }
});

// 获取操作日志记录
const fetchOperationLogs = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value.toString());
    params.append('page_size', pageSize.value.toString());
    
    if (searchParams.adminId && searchParams.adminId.trim()) {
      const adminIdNum = parseInt(searchParams.adminId.trim());
      if (!isNaN(adminIdNum)) {
        params.append('admin_id', adminIdNum.toString());
      }
    }
    
    if (searchParams.operationType && searchParams.operationType.trim()) {
      params.append('operation_type', searchParams.operationType.trim());
    }
    
    // 日期处理
    if (searchParams.startDate) {
      params.append('start_date', searchParams.startDate);
    }
    
    if (searchParams.endDate) {
      params.append('end_date', searchParams.endDate);
    }

    // 获取并添加当前管理员ID
    const adminId = localStorage.getItem('admin_id');
    if (adminId) {
      const adminIdNum = parseInt(adminId);
      if (!isNaN(adminIdNum)) {
        params.append('current_admin_id', adminIdNum.toString());
      }
    }
    
    // 发送请求
    const response = await fetch(`${apiBaseUrl.value}/admin/operation-logs?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      }
    });
    
    // 检查响应状态
    if (!response.ok) {
      const errorText = await response.text();
      console.error('API错误响应:', response.status, errorText);
      throw new Error(`API请求失败: ${response.status} ${errorText}`);
    }
    
    const data = await response.json();
    
    if (data.code === 200) {
      operationLogs.value = data.data.logs;
      totalItems.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取操作日志失败');
    }
  } catch (error) {
    console.error('获取操作日志失败:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 根据操作类型返回不同的标签类型
const getOperationTypeTag = (type) => {
  const typeMap = {
    'login': 'success',
    'logout': 'info',
    'query': 'primary',
    'create': 'success',
    'update': 'warning',
    'delete': 'danger'
  };
  
  return typeMap[type] || 'info';
};

// 搜索日志
const searchLogs = () => {
  currentPage.value = 1;
  fetchOperationLogs();
};

// 重置搜索参数
const resetSearchParams = () => {
  Object.keys(searchParams).forEach(key => {
    searchParams[key] = '';
  });
  dateRange.value = [];
  currentPage.value = 1;
  fetchOperationLogs();
};

// 处理分页大小变化
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchOperationLogs();
};

// 处理当前页变化
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchOperationLogs();
};

// 显示日志详情
const showLogDetail = (log) => {
  selectedLog.value = log;
  detailDialogVisible.value = true;
};

// 生命周期钩子
onMounted(() => {
  // 检查管理员身份
  const isAdmin = localStorage.getItem('isAdmin') === 'true';
  if (!isAdmin) {
    ElMessage.error('只有管理员才能访问此页面');
    return;
  }
  
  // 加载操作日志记录
  fetchOperationLogs();
});
</script>

<style scoped>
.operation-logs-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 24px;
  font-size: 24px;
  font-weight: 500;
  color: #333;
}

.search-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.table-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.pagination-container {
  margin-top: 20px;
  text-align: right;
}

.log-detail {
  padding: 10px;
}

.operation-desc {
  line-height: 1.5;
  word-break: break-all;
}

/* 修复按钮点击后出现的黑色边框 */
:deep(.el-button:focus),
:deep(.el-button:focus-visible) {
  outline: none !important;
  box-shadow: none !important;
  border-color: initial;
}

/* 改善表格内容样式 */
:deep(.el-table__header-wrapper th) {
  font-weight: bold;
}

:deep(.el-pagination) {
  margin-top: 20px;
  justify-content: flex-end;
}
</style> 