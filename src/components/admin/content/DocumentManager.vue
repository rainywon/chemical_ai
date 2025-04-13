<template>
  <div class="document-manager">
    <div class="page-header">
    <h1>知识文档管理</h1>
      <el-button type="primary" @click="handleUploadDocument">
        <el-icon><Upload /></el-icon>上传文档
      </el-button>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="文档标题">
          <el-input v-model="searchForm.title" placeholder="请输入文档标题"></el-input>
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="searchForm.category_id" placeholder="请选择分类" clearable>
            <el-option label="全部" value=""></el-option>
            <el-option 
              v-for="item in categoryOptions" 
              :key="item.category_id" 
              :label="item.category_name" 
              :value="item.category_id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
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
    
    <!-- 文档列表 -->
    <div class="document-list">
      <el-table 
        :data="documentList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="document_id" label="文档ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="title" label="文档标题" min-width="200" align="left" :show-overflow-tooltip="true"></el-table-column>
        <el-table-column prop="category_name" label="分类" min-width="100" align="center"></el-table-column>
        <el-table-column prop="file_type" label="文件类型" min-width="100" align="center"></el-table-column>
        <el-table-column prop="file_size" label="文件大小" min-width="100" align="center">
          <template #default="scope">
            {{ formatFileSize(scope.row.file_size) }}
          </template>
        </el-table-column>
        <el-table-column prop="author" label="作者" min-width="100" align="center"></el-table-column>
        <el-table-column prop="publish_date" label="发布日期" min-width="120" align="center"></el-table-column>
        <el-table-column prop="view_count" label="查看次数" min-width="100" align="center"></el-table-column>
        <el-table-column prop="is_published" label="状态" min-width="80" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_published === 1 ? 'success' : 'info'">
              {{ scope.row.is_published === 1 ? '已发布' : '未发布' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="200" align="center" fixed="right">
          <template #default="scope">
            <el-button size="small" type="primary" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button 
              size="small" 
              :type="scope.row.is_published === 1 ? 'warning' : 'success'"
              @click="handleTogglePublish(scope.row)">
              {{ scope.row.is_published === 1 ? '取消发布' : '发布' }}
            </el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            <el-button size="small" type="info" @click="handleDownload(scope.row)">下载</el-button>
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

    <!-- 上传文档对话框 -->
    <el-dialog 
      title="上传文档" 
      v-model="uploadDialogVisible" 
      width="600px"
      :close-on-click-modal="false">
      <el-form 
        ref="documentFormRef"
        :model="documentForm" 
        :rules="documentRules"
        label-width="100px">
        <el-form-item label="文档标题" prop="title">
          <el-input v-model="documentForm.title" placeholder="请输入文档标题"></el-input>
        </el-form-item>
        <el-form-item label="所属分类" prop="category_id">
          <el-select 
            v-model="documentForm.category_id" 
            placeholder="请选择分类"
            style="width: 100%">
            <el-option 
              v-for="item in categoryOptions" 
              :key="item.category_id" 
              :label="item.category_name" 
              :value="item.category_id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="文档文件" prop="file">
          <el-upload
            class="upload-demo"
            :action="`${API_BASE_URL}/admin/content/documents/upload`"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :before-upload="beforeUpload"
            :limit="1"
            :auto-upload="false"
            ref="uploadRef">
            <template #trigger>
              <el-button type="primary">选择文件</el-button>
            </template>
            <template #tip>
              <div class="el-upload__tip">
                支持上传PDF、DOCX、DOC等文档格式，文件大小不超过20MB
              </div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="作者" prop="author">
          <el-input v-model="documentForm.author" placeholder="请输入文档作者"></el-input>
        </el-form-item>
        <el-form-item label="发布日期" prop="publish_date">
          <el-date-picker
            v-model="documentForm.publish_date"
            type="date"
            placeholder="选择发布日期"
            style="width: 100%">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="文档描述" prop="description">
          <el-input 
            v-model="documentForm.description" 
            type="textarea" 
            :rows="4" 
            placeholder="请输入文档描述">
          </el-input>
        </el-form-item>
        <el-form-item label="是否发布" prop="is_published">
          <el-switch 
            v-model="documentForm.is_published"
            :active-value="1"
            :inactive-value="0">
          </el-switch>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="uploadDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitUpload" :loading="submitLoading">上传</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 编辑文档对话框 -->
    <el-dialog 
      title="编辑文档" 
      v-model="editDialogVisible" 
      width="600px"
      :close-on-click-modal="false">
      <el-form 
        ref="editFormRef"
        :model="documentForm" 
        :rules="documentRules"
        label-width="100px">
        <el-form-item label="文档标题" prop="title">
          <el-input v-model="documentForm.title" placeholder="请输入文档标题"></el-input>
        </el-form-item>
        <el-form-item label="所属分类" prop="category_id">
          <el-select 
            v-model="documentForm.category_id" 
            placeholder="请选择分类"
            style="width: 100%">
            <el-option 
              v-for="item in categoryOptions" 
              :key="item.category_id" 
              :label="item.category_name" 
              :value="item.category_id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="作者" prop="author">
          <el-input v-model="documentForm.author" placeholder="请输入文档作者"></el-input>
        </el-form-item>
        <el-form-item label="发布日期" prop="publish_date">
          <el-date-picker
            v-model="documentForm.publish_date"
            type="date"
            placeholder="选择发布日期"
            style="width: 100%">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="文档描述" prop="description">
          <el-input 
            v-model="documentForm.description" 
            type="textarea" 
            :rows="4" 
            placeholder="请输入文档描述">
          </el-input>
        </el-form-item>
        <el-form-item label="是否发布" prop="is_published">
          <el-switch 
            v-model="documentForm.is_published"
            :active-value="1"
            :inactive-value="0">
          </el-switch>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitEdit" :loading="submitLoading">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Upload } from '@element-plus/icons-vue';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const submitLoading = ref(false);
const documentList = ref([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const uploadDialogVisible = ref(false);
const editDialogVisible = ref(false);
const currentDocumentId = ref(null);
const categoryOptions = ref([]);
const uploadRef = ref(null);

// 搜索表单
const searchForm = reactive({
  title: '',
  category_id: '',
  is_published: ''
});

// 文档表单
const documentFormRef = ref(null);
const editFormRef = ref(null);
const documentForm = reactive({
  title: '',
  category_id: null,
  author: '',
  publish_date: new Date(),
  description: '',
  is_published: 1,
  file: null
});

// 表单验证规则
const documentRules = {
  title: [
    { required: true, message: '请输入文档标题', trigger: 'blur' },
    { max: 100, message: '文档标题不能超过100个字符', trigger: 'blur' }
  ],
  category_id: [
    { required: true, message: '请选择所属分类', trigger: 'change' }
  ],
  author: [
    { max: 50, message: '作者不能超过50个字符', trigger: 'blur' }
  ],
  description: [
    { max: 500, message: '描述不能超过500个字符', trigger: 'blur' }
  ]
};

// 初始化
onMounted(() => {
  fetchCategoryOptions();
  fetchDocumentList();
});

// 获取分类选项
const fetchCategoryOptions = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/content/categories`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      categoryOptions.value = data.data.categories;
    } else {
      ElMessage.error(data.message || '获取分类选项失败');
    }
  } catch (error) {
    console.error('获取分类选项错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 获取文档列表
const fetchDocumentList = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value);
    params.append('page_size', pageSize.value);
    
    if (searchForm.title) {
      params.append('title', searchForm.title);
    }
    
    if (searchForm.category_id) {
      params.append('category_id', searchForm.category_id);
    }
    
    if (searchForm.is_published !== '') {
      params.append('is_published', searchForm.is_published);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/content/documents?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      documentList.value = data.data.documents;
      total.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取文档列表失败');
    }
  } catch (error) {
    console.error('获取文档列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 格式化文件大小
const formatFileSize = (size) => {
  if (!size) return '0 KB';
  const sizeInKB = size;
  if (sizeInKB < 1024) {
    return `${sizeInKB} KB`;
  } else {
    return `${(sizeInKB / 1024).toFixed(2)} MB`;
  }
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  fetchDocumentList();
};

// 重置搜索表单
const resetSearchForm = () => {
  searchForm.title = '';
  searchForm.category_id = '';
  searchForm.is_published = '';
  currentPage.value = 1;
  fetchDocumentList();
};

// 分页大小改变
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchDocumentList();
};

// 当前页码改变
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchDocumentList();
};

// 打开上传文档对话框
const handleUploadDocument = () => {
  resetDocumentForm();
  uploadDialogVisible.value = true;
};

// 重置文档表单
const resetDocumentForm = () => {
  if (documentFormRef.value) {
    documentFormRef.value.resetFields();
  }
  documentForm.title = '';
  documentForm.category_id = null;
  documentForm.author = '';
  documentForm.publish_date = new Date();
  documentForm.description = '';
  documentForm.is_published = 1;
  documentForm.file = null;
  
  // 清空上传列表
  if (uploadRef.value) {
    uploadRef.value.clearFiles();
  }
};

// 打开编辑文档对话框
const handleEdit = (row) => {
  currentDocumentId.value = row.document_id;
  
  // 填充表单数据
  documentForm.title = row.title;
  documentForm.category_id = row.category_id;
  documentForm.author = row.author || '';
  documentForm.publish_date = row.publish_date ? new Date(row.publish_date) : new Date();
  documentForm.description = row.description || '';
  documentForm.is_published = row.is_published;
  
  editDialogVisible.value = true;
};

// 处理上传文件之前的钩子
const beforeUpload = (file) => {
  const isValidType = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].includes(file.type);
  const isLt20M = file.size / 1024 / 1024 < 20;

  if (!isValidType) {
    ElMessage.error('只能上传PDF/DOC/DOCX文件!');
    return false;
  }
  if (!isLt20M) {
    ElMessage.error('文件大小不能超过20MB!');
    return false;
  }
  
  documentForm.file = file;
  return true;
};

// 处理上传成功
const handleUploadSuccess = (response, file, fileList) => {
  if (response.code === 200) {
    documentForm.file_path = response.data.file_path;
    documentForm.file_size = response.data.file_size;
    documentForm.file_type = response.data.file_type;
    ElMessage.success('文件上传成功!');
  } else {
    ElMessage.error(response.message || '文件上传失败');
  }
};

// 处理上传失败
const handleUploadError = () => {
  ElMessage.error('文件上传失败，请稍后再试');
};

// 处理预览文件
const handlePreview = (file) => {
  // 可以实现预览逻辑，例如打开新窗口预览文件
  console.log(file);
};

// 处理移除文件
const handleRemove = () => {
  documentForm.file = null;
};

// 提交上传
const submitUpload = async () => {
  if (!documentFormRef.value) return;
  
  await documentFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    if (!documentForm.file && !uploadRef.value.uploadFiles.length) {
      ElMessage.error('请选择要上传的文件');
      return;
    }
    
    submitLoading.value = true;
    
    try {
      // 先上传文件
      if (uploadRef.value.uploadFiles.length > 0) {
        await uploadRef.value.submit();
        
        // 如果没有文件路径，说明上传失败或还没完成
        if (!documentForm.file_path) {
          submitLoading.value = false;
          return;
        }
      }
      
      // 然后提交文档信息
      const formData = {
        title: documentForm.title,
        category_id: documentForm.category_id,
        author: documentForm.author,
        publish_date: documentForm.publish_date ? formatDate(documentForm.publish_date) : null,
        description: documentForm.description,
        is_published: documentForm.is_published,
        file_path: documentForm.file_path,
        file_size: documentForm.file_size,
        file_type: documentForm.file_type,
        admin_id: localStorage.getItem('admin_id')
      };
      
      const response = await fetch(`${API_BASE_URL}/admin/content/documents`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success('文档上传成功');
        uploadDialogVisible.value = false;
        fetchDocumentList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '文档信息提交失败');
      }
    } catch (error) {
      console.error('文档上传错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    } finally {
      submitLoading.value = false;
    }
  });
};

// 提交编辑
const submitEdit = async () => {
  if (!editFormRef.value) return;
  
  await editFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    submitLoading.value = true;
    try {
      const formData = {
        title: documentForm.title,
        category_id: documentForm.category_id,
        author: documentForm.author,
        publish_date: documentForm.publish_date ? formatDate(documentForm.publish_date) : null,
        description: documentForm.description,
        is_published: documentForm.is_published,
        admin_id: localStorage.getItem('admin_id')
      };
      
      const response = await fetch(`${API_BASE_URL}/admin/content/documents/${currentDocumentId.value}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success('文档更新成功');
        editDialogVisible.value = false;
        fetchDocumentList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '文档更新失败');
      }
    } catch (error) {
      console.error('更新文档错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    } finally {
      submitLoading.value = false;
    }
  });
};

// 格式化日期
const formatDate = (date) => {
  const d = new Date(date);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

// 处理切换发布状态
const handleTogglePublish = async (row) => {
  const action = row.is_published === 1 ? '取消发布' : '发布';
  const newStatus = row.is_published === 1 ? 0 : 1;
  
  ElMessageBox.confirm(
    `确定要${action}文档 "${row.title}" 吗？`,
    `${action}确认`,
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: row.is_published === 1 ? 'warning' : 'success'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/documents/${row.document_id}/status`, {
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
        fetchDocumentList(); // 刷新列表
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

// 处理删除文档
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `确定要删除文档 "${row.title}" 吗？删除后将无法恢复。`,
    '删除确认',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/documents/${row.document_id}`, {
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
        ElMessage.success('删除文档成功');
        fetchDocumentList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '删除文档失败');
      }
    } catch (error) {
      console.error('删除文档错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 取消删除，不做操作
  });
};

// 处理下载文档
const handleDownload = (row) => {
  window.open(`${API_BASE_URL}/admin/content/documents/${row.document_id}/download`, '_blank');
};
</script>

<style scoped>
.document-manager {
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

.document-list {
  margin-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

:deep(.el-upload) {
  width: 100%;
}

:deep(.el-upload-dragger) {
  width: 100%;
}

:deep(.el-dialog__body) {
  padding-top: 10px;
}
</style> 