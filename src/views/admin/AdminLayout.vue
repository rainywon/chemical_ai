<template>
  <div class="admin-layout">
    <!-- 侧边栏 -->
    <div class="sidebar">
      <div class="logo">
        <img src="../../assets/product.png" alt="Logo" />
        <span>天工AI管理系统</span>
      </div>
      
      <!-- 导航菜单 -->
      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        background-color="#001529"
        text-color="#fff"
        active-text-color="#409EFF"
        router
      >
        <!-- 系统监控 -->
        <el-sub-menu index="/admin/monitor">
          <template #title>
            <el-icon><Monitor /></el-icon>
            <span>系统监控</span>
          </template>
          <el-menu-item index="/admin/monitor/conversation">对话数据统计</el-menu-item>
          <el-menu-item index="/admin/monitor/users">用户活跃度监控</el-menu-item>
        </el-sub-menu>
        
        <!-- 用户管理 -->
        <el-sub-menu index="/admin/users">
          <template #title>
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </template>
          <el-menu-item index="/admin/users/list">用户列表查看</el-menu-item>
          <el-menu-item index="/admin/users/status">用户账号状态管理</el-menu-item>
          <el-menu-item index="/admin/users/search">用户搜索和筛选</el-menu-item>
          <el-menu-item index="/admin/users/login-history">用户登录历史</el-menu-item>
        </el-sub-menu>
        
        <!-- 管理员管理 -->
        <el-sub-menu index="/admin/admins">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>管理员管理</span>
          </template>
          <el-menu-item index="/admin/admins/list">管理员账号列表</el-menu-item>
          <el-menu-item index="/admin/admins/edit">添加/编辑管理员</el-menu-item>
          <el-menu-item index="/admin/admins/roles">角色权限设置</el-menu-item>
          <el-menu-item index="/admin/admins/logs">管理员操作日志</el-menu-item>
        </el-sub-menu>
        
        <!-- 内容管理 -->
        <el-sub-menu index="/admin/content">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>内容管理</span>
          </template>
          <el-menu-item index="/admin/content/categories">知识库分类管理</el-menu-item>
          <el-menu-item index="/admin/content/documents">知识文档管理</el-menu-item>
          <el-menu-item index="/admin/content/emergency">应急处理方案管理</el-menu-item>
          <el-menu-item index="/admin/content/review">内容审核机制</el-menu-item>
        </el-sub-menu>
        
        <!-- 反馈管理 -->
        <el-sub-menu index="/admin/feedback">
          <template #title>
            <el-icon><Comment /></el-icon>
            <span>反馈管理</span>
          </template>
          <el-menu-item index="/admin/feedback/list">用户反馈列表</el-menu-item>
          <el-menu-item index="/admin/feedback/statistics">反馈分类统计</el-menu-item>
          <el-menu-item index="/admin/feedback/status">反馈处理状态管理</el-menu-item>
          <el-menu-item index="/admin/feedback/ratings">内容评价分析</el-menu-item>
        </el-sub-menu>
        
        <!-- 系统设置 -->
        <el-sub-menu index="/admin/settings">
          <template #title>
            <el-icon><Tools /></el-icon>
            <span>系统设置</span>
          </template>
          <el-menu-item index="/admin/settings/ai-model">AI模型配置</el-menu-item>
          <el-menu-item index="/admin/settings/system-params">系统参数设置</el-menu-item>
          <el-menu-item index="/admin/settings/registration">用户注册策略</el-menu-item>
        </el-sub-menu>
        
        <!-- 返回前台 -->
        <el-menu-item index="/">
          <el-icon><Back /></el-icon>
          <span>返回前台</span>
        </el-menu-item>
      </el-menu>
    </div>
    
    <!-- 内容区域 -->
    <div class="content">
      <div class="header">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/admin' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="index">
              {{ item }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        
        <div class="user-info">
          <el-dropdown>
            <span class="dropdown-link">
              管理员
              <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item>修改密码</el-dropdown-item>
                <el-dropdown-item>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
      
      <div class="main-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { 
  Monitor, User, Setting, Document, 
  Comment, Tools, Back, ArrowDown 
} from '@element-plus/icons-vue';

const route = useRoute();
const activeMenu = ref('');
const breadcrumbs = ref([]);

// 获取当前路由对应的菜单项
onMounted(() => {
  updateActiveMenu();
});

// 更新活动菜单和面包屑
const updateActiveMenu = () => {
  activeMenu.value = route.path;
  
  // 生成面包屑导航
  const pathParts = route.path.split('/').filter(Boolean);
  const crumbs = [];
  
  if (pathParts.length > 1) {
    pathParts.slice(1).forEach(part => {
      // 转换路径为可读性更好的文本
      let text = '';
      switch (part) {
        case 'monitor': text = '系统监控'; break;
        case 'conversation': text = '对话数据统计'; break;
        case 'users': 
          if (pathParts[1] === 'monitor') {
            text = '用户活跃度监控';
          } else {
            text = '用户管理';
          }
          break;
        case 'list': text = '用户列表'; break;
        case 'status': text = '账号状态管理'; break;
        case 'search': text = '用户搜索'; break;
        case 'login-history': text = '登录历史'; break;
        case 'admins': text = '管理员管理'; break;
        case 'edit': text = '添加/编辑管理员'; break;
        case 'roles': text = '角色权限设置'; break;
        case 'logs': text = '操作日志'; break;
        case 'content': text = '内容管理'; break;
        case 'categories': text = '知识库分类'; break;
        case 'documents': text = '知识文档'; break;
        case 'emergency': text = '应急处理方案'; break;
        case 'review': text = '内容审核'; break;
        case 'feedback': text = '反馈管理'; break;
        case 'statistics': text = '反馈分类统计'; break;
        case 'ratings': text = '内容评价分析'; break;
        case 'settings': text = '系统设置'; break;
        case 'ai-model': text = 'AI模型配置'; break;
        case 'system-params': text = '系统参数'; break;
        case 'registration': text = '注册策略'; break;
        default: text = part.charAt(0).toUpperCase() + part.slice(1);
      }
      crumbs.push(text);
    });
  }
  
  breadcrumbs.value = crumbs;
};

// 监听路由变化，实时更新菜单和面包屑
watch(() => route.path, (newPath) => {
  updateActiveMenu();
});
</script>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 240px;
  background-color: #001529;
  color: white;
  overflow-y: auto;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  z-index: 1000;
}

.logo {
  display: flex;
  align-items: center;
  padding: 16px;
  background-color: #002140;
  height: 64px;
}

.logo img {
  width: 32px;
  height: 32px;
  margin-right: 8px;
}

.logo span {
  font-size: 18px;
  font-weight: bold;
  color: white;
}

.sidebar-menu {
  border-right: none;
}

.content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  margin-left: 240px; /* 与侧边栏宽度相同 */
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  height: 64px;
  background-color: white;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  position: fixed;
  top: 0;
  left: 240px; /* 与侧边栏宽度相同 */
  right: 0;
  z-index: 999;
}

.breadcrumb {
  font-size: 14px;
}

.user-info {
  display: flex;
  align-items: center;
}

.dropdown-link {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #333;
}

.main-content {
  flex: 1;
  padding: 20px;
  background-color: #f0f2f5;
  overflow: auto;
  margin-top: 64px; /* 与头部高度相同 */
}

/* 深色模式下menu样式调整 */
:deep(.el-menu) {
  border-right: none;
}

:deep(.el-sub-menu__title) {
  &:hover {
    background-color: #001f3f !important;
  }
}

:deep(.el-menu-item) {
  &:hover {
    background-color: #001f3f !important;
  }
}
</style> 