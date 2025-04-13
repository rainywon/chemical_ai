<template>
  <div class="content-review">
    <div class="page-header">
      <h1>内容审核管理</h1>
      <div class="header-actions">
        <el-button type="primary" @click="refreshData">
          <el-icon><Refresh /></el-icon>刷新数据
        </el-button>
      </div>
    </div>
    
    <!-- 搜索和筛选区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="评分">
          <el-select v-model="searchForm.rating" placeholder="请选择评分" clearable>
            <el-option label="全部" value=""></el-option>
            <el-option label="1星" :value="1"></el-option>
            <el-option label="2星" :value="2"></el-option>
            <el-option label="3星" :value="3"></el-option>
            <el-option label="4星" :value="4"></el-option>
            <el-option label="5星" :value="5"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="反馈类型">
          <el-select v-model="searchForm.feedback_option" placeholder="请选择反馈类型" clearable>
            <el-option label="全部" value=""></el-option>
            <el-option label="不准确" value="inaccurate"></el-option>
            <el-option label="不相关" value="irrelevant"></el-option>
            <el-option label="不完整" value="incomplete"></el-option>
            <el-option label="不正确" value="incorrect"></el-option>
            <el-option label="其他" value="other"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearchForm">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 反馈内容列表 -->
    <div class="feedback-list">
      <el-table 
        :data="feedbackList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="id" label="ID" min-width="80" align="center"></el-table-column>
        <el-table-column label="评分" min-width="100" align="center">
          <template #default="scope">
            <el-rate
              v-model="scope.row.rating"
              disabled
              text-color="#ff9900"
              score-template="{value}">
            </el-rate>
          </template>
        </el-table-column>
        <el-table-column prop="feedback_option" label="反馈类型" min-width="120" align="center">
          <template #default="scope">
            <el-tag :type="getFeedbackOptionTag(scope.row.feedback_option)">
              {{ getFeedbackOptionLabel(scope.row.feedback_option) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="feedback" label="反馈内容" min-width="200" align="left" :show-overflow-tooltip="true"></el-table-column>
        <el-table-column prop="created_at" label="提交时间" min-width="160" align="center"></el-table-column>
        <el-table-column label="操作" min-width="150" align="center" fixed="right">
          <template #default="scope">
            <el-button size="small" type="primary" @click="handleViewDetail(scope.row)">查看详情</el-button>
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

    <!-- 反馈详情对话框 -->
    <el-dialog 
      title="反馈详情" 
      v-model="detailDialogVisible" 
      width="800px"
      :close-on-click-modal="false">
      <div class="feedback-detail" v-if="currentFeedback">
        <el-descriptions direction="vertical" :column="1" border>
          <el-descriptions-item label="评分">
            <el-rate
              v-model="currentFeedback.rating"
              disabled
              text-color="#ff9900"
              score-template="{value}">
            </el-rate>
          </el-descriptions-item>
          <el-descriptions-item label="反馈类型">
            <el-tag :type="getFeedbackOptionTag(currentFeedback.feedback_option)">
              {{ getFeedbackOptionLabel(currentFeedback.feedback_option) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="反馈内容">
            {{ currentFeedback.feedback }}
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">
            {{ currentFeedback.created_at }}
          </el-descriptions-item>
        </el-descriptions>
        
        <div class="conversation-container">
          <h3>对话内容</h3>
          <div class="conversation">
            <div class="message user-message">
              <div class="message-header">
                <span class="message-role">用户问题</span>
              </div>
              <div class="message-content">
                {{ currentFeedback.question }}
              </div>
            </div>
            <div class="message ai-message">
              <div class="message-header">
                <span class="message-role">AI回答</span>
              </div>
              <div class="message-content">
                {{ currentFeedback.message }}
              </div>
            </div>
          </div>
        </div>
        
        <div class="analysis-container">
          <h3>反馈分析</h3>
          <div class="analysis">
            <p>
              <strong>问题类型：</strong>{{ analyzeQuestionType(currentFeedback.question) }}
            </p>
            <p>
              <strong>回答质量：</strong>{{ analyzeAnswerQuality(currentFeedback.rating, currentFeedback.feedback_option) }}
            </p>
            <p>
              <strong>改进建议：</strong>{{ generateImprovement(currentFeedback) }}
            </p>
          </div>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
          <el-button type="danger" @click="handleDeleteFromDetail">删除反馈</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Refresh } from '@element-plus/icons-vue';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const feedbackList = ref([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const detailDialogVisible = ref(false);
const currentFeedback = ref(null);

// 搜索表单
const searchForm = reactive({
  rating: '',
  feedback_option: '',
  dateRange: []
});

// 初始化
onMounted(() => {
  fetchFeedbackList();
});

// 获取反馈列表
const fetchFeedbackList = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value);
    params.append('page_size', pageSize.value);
    
    if (searchForm.rating) {
      params.append('rating', searchForm.rating);
    }
    
    if (searchForm.feedback_option) {
      params.append('feedback_option', searchForm.feedback_option);
    }
    
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.append('start_date', searchForm.dateRange[0]);
      params.append('end_date', searchForm.dateRange[1]);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/content/feedback?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      feedbackList.value = data.data.feedback;
      total.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取反馈列表失败');
    }
  } catch (error) {
    console.error('获取反馈列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 获取反馈类型标签样式
const getFeedbackOptionTag = (option) => {
  const optionMap = {
    'inaccurate': 'danger',
    'irrelevant': 'warning',
    'incomplete': 'info',
    'incorrect': 'danger',
    'other': ''
  };
  return optionMap[option] || '';
};

// 获取反馈类型标签文字
const getFeedbackOptionLabel = (option) => {
  const labelMap = {
    'inaccurate': '不准确',
    'irrelevant': '不相关',
    'incomplete': '不完整',
    'incorrect': '不正确',
    'other': '其他'
  };
  return labelMap[option] || option;
};

// 分析问题类型
const analyzeQuestionType = (question) => {
  if (!question) return '未知';
  
  // 简单的关键词匹配分析
  if (question.includes('如何') || question.includes('怎么')) {
    return '操作指导型';
  } else if (question.includes('什么') || question.includes('是否')) {
    return '知识解答型';
  } else if (question.includes('应该') || question.includes('建议')) {
    return '建议咨询型';
  }
  
  return '一般咨询型';
};

// 分析回答质量
const analyzeAnswerQuality = (rating, option) => {
  if (rating <= 2) {
    return '较差';
  } else if (rating === 3) {
    return '一般';
  } else {
    return '良好';
  }
};

// 生成改进建议
const generateImprovement = (feedback) => {
  if (!feedback) return '';
  
  const optionMap = {
    'inaccurate': '需要提高回答的准确性，确保事实和数据的正确性。',
    'irrelevant': '需要提高回答的相关性，确保回答直接针对用户的问题。',
    'incomplete': '需要提供更全面的信息，补充必要的细节和背景。',
    'incorrect': '需要纠正回答中的错误信息，确保回答的正确性。',
    'other': '需根据具体反馈内容进行针对性改进。'
  };
  
  return optionMap[feedback.feedback_option] || '根据用户反馈进行有针对性的改进。';
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  fetchFeedbackList();
};

// 重置搜索表单
const resetSearchForm = () => {
  searchForm.rating = '';
  searchForm.feedback_option = '';
  searchForm.dateRange = [];
  currentPage.value = 1;
  fetchFeedbackList();
};

// 分页大小改变
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchFeedbackList();
};

// 当前页码改变
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchFeedbackList();
};

// 查看反馈详情
const handleViewDetail = (row) => {
  currentFeedback.value = { ...row };
  detailDialogVisible.value = true;
};

// 处理删除反馈
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `确定要删除ID为 ${row.id} 的反馈记录吗？删除后将无法恢复。`,
    '删除确认',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/feedback/${row.id}`, {
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
        ElMessage.success('删除反馈成功');
        fetchFeedbackList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '删除反馈失败');
      }
    } catch (error) {
      console.error('删除反馈错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 取消删除，不做操作
  });
};

// 从详情对话框删除反馈
const handleDeleteFromDetail = () => {
  if (!currentFeedback.value) return;
  
  ElMessageBox.confirm(
    `确定要删除ID为 ${currentFeedback.value.id} 的反馈记录吗？删除后将无法恢复。`,
    '删除确认',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/feedback/${currentFeedback.value.id}`, {
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
        ElMessage.success('删除反馈成功');
        detailDialogVisible.value = false;
        fetchFeedbackList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '删除反馈失败');
      }
    } catch (error) {
      console.error('删除反馈错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 取消删除，不做操作
  });
};

// 刷新数据
const refreshData = () => {
  fetchFeedbackList();
};
</script>

<style scoped>
.content-review {
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

.feedback-list {
  margin-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.feedback-detail {
  margin-top: 20px;
}

.conversation-container {
  margin-top: 30px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 15px;
}

.conversation-container h3 {
  margin-top: 0;
  margin-bottom: 15px;
  font-size: 16px;
  font-weight: 500;
}

.conversation {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.message {
  padding: 15px;
  border-radius: 8px;
}

.user-message {
  background-color: #f2f6fc;
}

.ai-message {
  background-color: #f0f9eb;
}

.message-header {
  margin-bottom: 10px;
}

.message-role {
  font-weight: bold;
  font-size: 14px;
}

.message-content {
  white-space: pre-wrap;
  line-height: 1.5;
}

.analysis-container {
  margin-top: 30px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 15px;
}

.analysis-container h3 {
  margin-top: 0;
  margin-bottom: 15px;
  font-size: 16px;
  font-weight: 500;
}

.analysis {
  line-height: 1.8;
}
</style> 