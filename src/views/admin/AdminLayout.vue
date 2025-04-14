<template>
  <div class="admin-layout" :class="{ 'dark-mode': isDarkMode }">
    <!-- 侧边栏 -->
    <div class="sidebar" :class="{ 'collapsed': isCollapsed }">
      <div class="logo">
        <img src="../../assets/product.png" alt="Logo" />
        <span v-if="!isCollapsed">天工AI管理系统</span>
      </div>
      
      <!-- 折叠按钮 -->
      <div class="collapse-btn" @click="toggleCollapse">
        <el-icon v-if="isCollapsed"><Expand /></el-icon>
        <el-icon v-else><Fold /></el-icon>
      </div>
      
      <!-- 导航菜单 -->
      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        :background-color="isDarkMode ? '#1a1a1a' : '#001529'"
        :text-color="isDarkMode ? '#e0e0e0' : '#fff'"
        :active-text-color="isDarkMode ? '#66b1ff' : '#409EFF'"
        :collapse="isCollapsed"
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
          <el-menu-item index="/admin/users/user-management">用户查询与管理</el-menu-item>
          <el-menu-item index="/admin/users/login-history">用户登录历史</el-menu-item>
        </el-sub-menu>
        
        <!-- 管理员管理 -->
        <el-sub-menu index="/admin/admins">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>管理员管理</span>
          </template>
          <el-menu-item index="/admin/admins/admin-management">管理员与角色管理</el-menu-item>
          <el-menu-item index="/admin/admins/logs">管理员操作日志</el-menu-item>
        </el-sub-menu>
        
        <!-- 内容管理 -->
        <el-sub-menu index="/admin/content">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>内容管理</span>
          </template>
          <el-menu-item index="/admin/content/knowledge-files">知识库文件管理</el-menu-item>
          <el-menu-item index="/admin/content/safety-materials">安全资料库</el-menu-item>
          <el-menu-item index="/admin/content/emergency-materials">应急处理资料库</el-menu-item>
        </el-sub-menu>
        
        <!-- 反馈管理 -->
        <el-sub-menu index="/admin/feedback">
          <template #title>
            <el-icon><Comment /></el-icon>
            <span>反馈管理</span>
          </template>
          <el-menu-item index="/admin/feedback/list">系统功能反馈</el-menu-item>
          <el-menu-item index="/admin/feedback/ratings">生成内容反馈</el-menu-item>
        </el-sub-menu>
        
        <!-- 系统设置 -->
        <el-sub-menu index="/admin/settings">
          <template #title>
            <el-icon><Tools /></el-icon>
            <span>系统设置</span>
          </template>
          <el-menu-item index="/admin/settings/system-params">系统参数设置</el-menu-item>
        </el-sub-menu>
        
        <!-- 返回前台 -->
        <el-menu-item index="/">
          <el-icon><Back /></el-icon>
          <span>返回前台</span>
        </el-menu-item>
      </el-menu>
    </div>
    
    <!-- 内容区域 -->
    <div class="content" :class="{ 'collapsed-content': isCollapsed }">
      <div class="header" :class="{ 'dark-header': isDarkMode }">
        <div class="header-left">
          <div class="breadcrumb">
            <el-breadcrumb separator="/">
              <el-breadcrumb-item :to="{ path: '/admin' }">首页</el-breadcrumb-item>
              <el-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="index">
                {{ item }}
              </el-breadcrumb-item>
            </el-breadcrumb>
          </div>
        </div>
        
        <div class="header-right">
          <!-- 搜索框 -->
          <div class="search-box">
            <el-input
              v-model="searchQuery"
              placeholder="搜索..."
              prefix-icon="Search"
              clearable
              @keyup.enter="handleSearch"
            />
          </div>
          
          <!-- 通知图标 -->
          <div class="notifications">
            <el-badge :value="3" :max="99" class="notification-badge">
              <el-icon size="20"><Bell /></el-icon>
            </el-badge>
          </div>
          
          <!-- 暗黑模式切换 -->
          <div class="theme-toggle" @click="toggleDarkMode">
            <el-icon v-if="isDarkMode" size="20"><Sunny /></el-icon>
            <el-icon v-else size="20"><Moon /></el-icon>
          </div>
          
          <!-- 用户信息 -->
          <div class="user-info">
            <el-dropdown trigger="click">
              <div class="user-avatar-info">
                <el-avatar :size="32" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
                <span class="dropdown-link">
                  管理员
                  <el-icon class="el-icon--right"><arrow-down /></el-icon>
                </span>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item>
                    <el-icon><UserFilled /></el-icon>个人资料
                  </el-dropdown-item>
                  <el-dropdown-item>
                    <el-icon><Lock /></el-icon>修改密码
                  </el-dropdown-item>
                  <el-dropdown-item divided>
                    <el-icon><SwitchButton /></el-icon>退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
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
  Monitor, User, Setting, Document, Comment, Tools, Back, ArrowDown, 
  Fold, Expand, Search, Bell, Sunny, Moon, UserFilled, Lock, SwitchButton
} from '@element-plus/icons-vue';

const route = useRoute();
const activeMenu = ref('');
const breadcrumbs = ref([]);
const isCollapsed = ref(false);
const isDarkMode = ref(false);
const searchQuery = ref('');

// 切换侧边栏折叠状态
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
  localStorage.setItem('adminSidebarCollapsed', isCollapsed.value.toString());
};

// 切换暗黑模式
const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value;
  localStorage.setItem('adminDarkMode', isDarkMode.value.toString());
  document.documentElement.classList.toggle('dark', isDarkMode.value);
};

// 搜索处理
const handleSearch = () => {
  if (searchQuery.value.trim()) {
    console.log('执行搜索:', searchQuery.value);
    // 这里可以实现搜索逻辑
  }
};

// 获取当前路由对应的菜单项
onMounted(() => {
  updateActiveMenu();
  
  // 从本地存储中恢复设置
  const savedCollapsed = localStorage.getItem('adminSidebarCollapsed');
  const savedDarkMode = localStorage.getItem('adminDarkMode');
  
  if (savedCollapsed) {
    isCollapsed.value = savedCollapsed === 'true';
  }
  
  if (savedDarkMode) {
    isDarkMode.value = savedDarkMode === 'true';
    document.documentElement.classList.toggle('dark', isDarkMode.value);
  }
});

// 更新活动菜单和面包屑
const updateActiveMenu = () => {
  activeMenu.value = route.path;
  
  // 生成面包屑导航
  const pathParts = route.path.split('/').filter(Boolean);
  const crumbs = [];
  
  // 如果是管理后台首页(/admin 或 /admin/dashboard)，不添加额外的面包屑
  if (route.path === '/admin' || route.path === '/admin/dashboard') {
    breadcrumbs.value = [];
    return;
  }
  
  if (pathParts.length > 1) {
    pathParts.slice(1).forEach(part => {
      // 转换路径为可读性更好的文本
      let text = '';
      switch (part) {
        case 'dashboard': return; // 跳过dashboard，不添加到面包屑
        case 'monitor': text = '系统监控'; break;
        case 'conversation': text = '对话数据统计'; break;
        case 'users': 
          if (pathParts[1] === 'monitor') {
            text = '用户活跃度监控';
          } else {
            text = '用户管理';
          }
          break;
        case 'user-management': text = '用户查询与管理'; break;
        case 'login-history': text = '用户登录历史'; break;
        case 'admins': text = '管理员管理'; break;
        case 'admin-management': text = '管理员与角色管理'; break;
        case 'logs': text = '操作日志'; break;
        case 'content': text = '内容资源管理'; break;
        case 'knowledge-files': text = '知识库管理'; break;
        case 'safety-materials': text = '安全文档库'; break;
        case 'emergency-materials': text = '应急预案库'; break;
        case 'review': text = '内容审核'; break;
        case 'feedback': text = '反馈管理'; break;
        case 'list': 
          if (pathParts[1] === 'feedback') {
            text = '系统功能反馈';
          } else {
            text = 'list';
          }
          break;
        case 'ratings': 
          if (pathParts[1] === 'feedback') {
            text = '生成内容反馈';
          } else {
            text = '内容评价分析';
          }
          break;
        case 'statistics': text = '反馈分类统计'; break;
        case 'status': text = '反馈处理状态管理'; break;
        case 'settings': text = '系统设置'; break;
        case 'system-params': text = '系统参数'; break;
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
  transition: all 0.3s;
}

.dark-mode {
  color: #e0e0e0;
  background-color: #121212;
}

.sidebar {
  width: 240px;
  background-color: #001529;
  color: white;
  overflow-y: auto;
  scrollbar-width: thin;
  -ms-overflow-style: none;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  z-index: 1000;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.sidebar.collapsed {
  width: 64px;
}

/* 定制滚动条样式 */
.sidebar::-webkit-scrollbar {
  width: 4px;
}

.sidebar::-webkit-scrollbar-thumb {
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
}

.sidebar::-webkit-scrollbar-track {
  background-color: transparent;
}

.logo {
  display: flex;
  align-items: center;
  padding: 16px;
  background-color: #002140;
  height: 64px;
  overflow: hidden;
  transition: all 0.3s;
}

.logo img {
  width: 32px;
  height: 32px;
  margin-right: 8px;
  transition: all 0.3s;
}

.logo span {
  font-size: 18px;
  font-weight: bold;
  color: white;
  white-space: nowrap;
  transition: opacity 0.3s;
}

.collapse-btn {
  text-align: center;
  line-height: 40px;
  cursor: pointer;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.65);
  transition: all 0.3s;
}

.collapse-btn:hover {
  color: white;
  background-color: rgba(255, 255, 255, 0.08);
}

.sidebar-menu {
  border-right: none;
}

.content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  margin-left: 240px;
  transition: all 0.3s;
}

.collapsed-content {
  margin-left: 64px;
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
  left: 240px;
  right: 0;
  z-index: 999;
  transition: all 0.3s;
}

.dark-header {
  background-color: #1a1a1a;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.2);
  color: #e0e0e0;
}

.collapsed-content .header {
  left: 64px;
}

.header-left, .header-right {
  display: flex;
  align-items: center;
}

.header-right {
  gap: 16px;
}

.breadcrumb {
  font-size: 14px;
}

.search-box {
  width: 200px;
  transition: width 0.3s;
}

.search-box:focus-within {
  width: 240px;
}

.notifications {
  position: relative;
  cursor: pointer;
}

.notification-badge :deep(.el-badge__content) {
  transform: translate(50%, -50%);
}

.theme-toggle {
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  border-radius: 50%;
  transition: background-color 0.3s;
}

.theme-toggle:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.dark-mode .theme-toggle:hover {
  background-color: rgba(255, 255, 255, 0.05);
}

.user-info {
  display: flex;
  align-items: center;
}

.user-avatar-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-avatar-info:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.dark-mode .user-avatar-info:hover {
  background-color: rgba(255, 255, 255, 0.05);
}

.dropdown-link {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #333;
  transition: color 0.3s;
}

.dark-mode .dropdown-link {
  color: #e0e0e0;
}

.main-content {
  flex: 1;
  padding: 20px;
  background-color: #f0f2f5;
  overflow: auto;
  margin-top: 64px;
  transition: background-color 0.3s;
}

.dark-mode .main-content {
  background-color: #1e1e1e;
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

.dark-mode :deep(.el-sub-menu__title) {
  &:hover {
    background-color: #252525 !important;
  }
}

.dark-mode :deep(.el-menu-item) {
  &:hover {
    background-color: #252525 !important;
  }
}
</style> 