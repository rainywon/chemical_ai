<template>
  <div class="category-manager">
    <div class="page-header">
      <h1>知识库分类管理</h1>
      <el-button type="primary" @click="handleAddCategory">
        <el-icon><Plus /></el-icon>添加分类
      </el-button>
    </div>

    <!-- 分类列表 -->
    <div class="category-list">
      <el-table 
        :data="categoryList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :row-key="row => row.category_id"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="category_id" label="分类ID" min-width="80" align="center"></el-table-column>
        <el-table-column label="分类名称" min-width="200" align="left">
          <template #default="scope">
            <div class="category-info">
              <el-icon v-if="scope.row.icon"><component :is="getIconComponent(scope.row.icon)" /></el-icon>
              <span v-else class="icon-placeholder">📁</span>
              <span class="category-name">{{ scope.row.category_name }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="250" align="left" :show-overflow-tooltip="true"></el-table-column>
        <el-table-column prop="sort_order" label="排序" min-width="80" align="center"></el-table-column>
        <el-table-column label="操作" min-width="200" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button size="small" type="success" @click="handleAddSubCategory(scope.row)">添加子分类</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 添加/编辑分类对话框 -->
    <el-dialog 
      :title="dialogType === 'add' ? '添加分类' : '编辑分类'" 
      v-model="dialogVisible" 
      width="500px"
      :close-on-click-modal="false">
      <el-form 
        ref="categoryFormRef"
        :model="categoryForm" 
        :rules="categoryRules"
        label-width="100px">
        <el-form-item label="分类名称" prop="category_name">
          <el-input v-model="categoryForm.category_name" placeholder="请输入分类名称"></el-input>
        </el-form-item>
        <el-form-item label="上级分类" prop="parent_id">
          <el-select 
            v-model="categoryForm.parent_id" 
            placeholder="选择上级分类"
            clearable
            filterable
            style="width: 100%">
            <el-option label="无 (顶级分类)" :value="null"></el-option>
            <el-option 
              v-for="item in parentCategoryOptions" 
              :key="item.category_id" 
              :label="item.category_name" 
              :value="item.category_id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="图标" prop="icon">
          <el-input v-model="categoryForm.icon" placeholder="输入Emoji或图标代码 (例如: 📕)"></el-input>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input 
            v-model="categoryForm.description" 
            type="textarea" 
            :rows="3" 
            placeholder="请输入分类描述">
          </el-input>
        </el-form-item>
        <el-form-item label="排序" prop="sort_order">
          <el-input-number v-model="categoryForm.sort_order" :min="0" :max="100"></el-input-number>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmitCategory" :loading="submitLoading">确认</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const submitLoading = ref(false);
const categoryList = ref([]);
const dialogVisible = ref(false);
const dialogType = ref('add'); // 对话框类型：'add'新增，'edit'编辑
const currentCategoryId = ref(null);

// 表单相关
const categoryFormRef = ref(null);
const categoryForm = reactive({
  category_name: '',
  parent_id: null,
  icon: '',
  description: '',
  sort_order: 0
});

// 表单验证规则
const categoryRules = {
  category_name: [
    { required: true, message: '请输入分类名称', trigger: 'blur' },
    { max: 50, message: '分类名称不能超过50个字符', trigger: 'blur' }
  ],
  description: [
    { max: 255, message: '描述不能超过255个字符', trigger: 'blur' }
  ],
  icon: [
    { max: 50, message: '图标不能超过50个字符', trigger: 'blur' }
  ]
};

// 计算可用于选择的父分类选项（排除自身及其子分类）
const parentCategoryOptions = computed(() => {
  if (dialogType.value === 'add') {
    return categoryList.value;
  } else {
    // 在编辑模式下需要排除自身及其子分类
    return categoryList.value.filter(item => {
      return item.category_id !== currentCategoryId.value;
      // 更复杂的逻辑可以添加，如检查子类
    });
  }
});

// 初始化
onMounted(() => {
  fetchCategoryList();
});

// 获取分类列表
const fetchCategoryList = async () => {
  loading.value = true;
  try {
    const response = await fetch(`${API_BASE_URL}/admin/content/categories`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      categoryList.value = data.data.categories;
    } else {
      ElMessage.error(data.message || '获取分类列表失败');
    }
  } catch (error) {
    console.error('获取分类列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 处理图标组件
const getIconComponent = (icon) => {
  // 这里可以根据图标字符串返回对应的图标组件
  // 如果使用的是Emoji，则直接在模板中显示
  return null;
};

// 重置表单
const resetForm = () => {
  if (categoryFormRef.value) {
    categoryFormRef.value.resetFields();
  }
  categoryForm.category_name = '';
  categoryForm.parent_id = null;
  categoryForm.icon = '';
  categoryForm.description = '';
  categoryForm.sort_order = 0;
};

// 打开添加分类对话框
const handleAddCategory = () => {
  dialogType.value = 'add';
  resetForm();
  dialogVisible.value = true;
};

// 打开添加子分类对话框
const handleAddSubCategory = (row) => {
  dialogType.value = 'add';
  resetForm();
  categoryForm.parent_id = row.category_id;
  dialogVisible.value = true;
};

// 打开编辑分类对话框
const handleEdit = (row) => {
  dialogType.value = 'edit';
  currentCategoryId.value = row.category_id;
  
  // 填充表单数据
  categoryForm.category_name = row.category_name;
  categoryForm.parent_id = row.parent_id;
  categoryForm.icon = row.icon || '';
  categoryForm.description = row.description || '';
  categoryForm.sort_order = row.sort_order || 0;
  
  dialogVisible.value = true;
};

// 处理分类表单提交
const handleSubmitCategory = async () => {
  if (!categoryFormRef.value) return;
  
  await categoryFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    submitLoading.value = true;
    try {
      const url = dialogType.value === 'add' 
        ? `${API_BASE_URL}/admin/content/categories` 
        : `${API_BASE_URL}/admin/content/categories/${currentCategoryId.value}`;
      
      const method = dialogType.value === 'add' ? 'POST' : 'PUT';
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          ...categoryForm,
          admin_id: localStorage.getItem('admin_id')
        })
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success(dialogType.value === 'add' ? '添加分类成功' : '更新分类成功');
        dialogVisible.value = false;
        fetchCategoryList(); // 刷新列表
      } else {
        ElMessage.error(data.message || (dialogType.value === 'add' ? '添加分类失败' : '更新分类失败'));
      }
    } catch (error) {
      console.error(dialogType.value === 'add' ? '添加分类错误:' : '更新分类错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    } finally {
      submitLoading.value = false;
    }
  });
};

// 处理删除分类
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `确定要删除分类 "${row.category_name}" 吗？删除后相关文档可能无法正常分类。`,
    '删除确认',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/admin/content/categories/${row.category_id}`, {
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
        ElMessage.success('删除分类成功');
        fetchCategoryList(); // 刷新列表
      } else {
        ElMessage.error(data.message || '删除分类失败');
      }
    } catch (error) {
      console.error('删除分类错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  }).catch(() => {
    // 取消删除，不做操作
  });
};
</script>

<style scoped>
.category-manager {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.category-list {
  margin-bottom: 20px;
}

.category-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon-placeholder {
  font-size: 18px;
}

.category-name {
  font-weight: 500;
}

:deep(.el-dialog__body) {
  padding-top: 10px;
}
</style> 