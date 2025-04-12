<template>
  <div class="user-management">
    
    <!-- 搜索和筛选区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="手机号">
          <el-input v-model="searchForm.mobile" placeholder="请输入手机号"></el-input>
        </el-form-item>
        <el-form-item label="注册时间">
          <el-date-picker
            v-model="searchForm.registrationRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="账号状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="正常" value="1"></el-option>
            <el-option label="禁用" value="0"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearchForm">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 用户列表 -->
    <div class="table-container">
      <el-table 
        :data="userList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="user_id" label="用户ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="mobile" label="手机号" min-width="120" align="center"></el-table-column>
        <el-table-column prop="register_time" label="注册时间" min-width="160" align="center"></el-table-column>
        <el-table-column prop="last_login_time" label="最后登录时间" min-width="160" align="center"></el-table-column>
        <el-table-column prop="status" label="账号状态" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="180" align="center">
          <template #default="scope">
            <el-button 
              size="small"
              :type="scope.row.status === 1 ? 'danger' : 'success'"
              @click="handleStatusChange(scope.row)"
              style="margin-right: 8px"
            >
              {{ scope.row.status === 1 ? '禁用' : '启用' }}
            </el-button>
            <el-button size="small" type="primary" @click="handleViewDetail(scope.row)">查看详情</el-button>
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
    
    <!-- 用户详情对话框 -->
    <el-dialog 
      title="用户详情" 
      v-model="dialogVisible" 
      width="500px"
      :close-on-click-modal="false"
    >
      <div class="user-detail" v-if="currentUser">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="用户ID">{{ currentUser.user_id }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ currentUser.mobile }}</el-descriptions-item>
          <el-descriptions-item label="注册时间">{{ currentUser.register_time }}</el-descriptions-item>
          <el-descriptions-item label="最后登录时间">{{ currentUser.last_login_time }}</el-descriptions-item>
          <el-descriptions-item label="账号状态">
            <el-tag :type="currentUser.status === 1 ? 'success' : 'danger'">
              {{ currentUser.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="主题偏好">{{ currentUser.theme_preference === 'light' ? '浅色' : '深色' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">关闭</el-button>
          <el-button 
            :type="currentUser && currentUser.status === 1 ? 'danger' : 'success'"
            @click="handleStatusChange(currentUser)"
          >
            {{ currentUser && currentUser.status === 1 ? '禁用账号' : '启用账号' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const userList = ref([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const dialogVisible = ref(false);
const currentUser = ref(null);

// 搜索表单
const searchForm = reactive({
  mobile: '',
  registrationRange: [],
  status: ''
});

// 获取用户列表
const fetchUserList = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value);
    params.append('page_size', pageSize.value);
    
    if (searchForm.mobile) {
      params.append('mobile', searchForm.mobile);
    }
    
    if (searchForm.status !== '') {
      params.append('status', searchForm.status);
    }
    
    if (searchForm.registrationRange && searchForm.registrationRange.length === 2) {
      const startDate = formatDate(searchForm.registrationRange[0]);
      const endDate = formatDate(searchForm.registrationRange[1]);
      params.append('start_date', startDate);
      params.append('end_date', endDate);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/users?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      userList.value = data.data.users;
      total.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取用户列表失败');
    }
  } catch (error) {
    console.error('获取用户列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 格式化日期
const formatDate = (date) => {
  const d = new Date(date);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  fetchUserList();
};

// 重置搜索表单
const resetSearchForm = () => {
  searchForm.mobile = '';
  searchForm.registrationRange = [];
  searchForm.status = '';
  currentPage.value = 1;
  fetchUserList();
};

// 分页大小改变
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchUserList();
};

// 当前页码改变
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchUserList();
};

// 查看用户详情
const handleViewDetail = (user) => {
  currentUser.value = { ...user };
  dialogVisible.value = true;
};

// 改变用户状态
const handleStatusChange = (user) => {
  if (!user) return;
  
  const action = user.status === 1 ? '禁用' : '启用';
  const newStatus = user.status === 1 ? 0 : 1;
  
  ElMessageBox.confirm(
    `确定要${action}用户 ${user.mobile} 的账号吗？`,
    `${action}确认`,
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/users/status`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          user_id: user.user_id,
          status: newStatus
        })
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success(`用户账号${action}成功`);
        
        // 更新本地数据
        if (currentUser.value && currentUser.value.user_id === user.user_id) {
          currentUser.value.status = newStatus;
        }
        
        // 刷新列表
        fetchUserList();
      } else {
        ElMessage.error(data.message || `用户账号${action}失败`);
      }
    } catch (error) {
      console.error(`${action}用户账号错误:`, error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 用户取消操作
  });
};

// 页面加载时获取用户列表
onMounted(() => {
  fetchUserList();
});
</script>

<style scoped>
.user-management {
  padding: 20px;
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

.user-detail {
  padding: 10px;
}

/* 添加操作按钮间距 */
.el-button + .el-button {
  margin-left: 8px;
}

/* 确保表格在小屏幕上也能水平滚动 */
@media (max-width: 1200px) {
  .table-container {
    overflow-x: auto;
  }
}
</style> 