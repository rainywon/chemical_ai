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
}

.sidebar {
  width: 240px;
  background-color: #001529;
  color: white;
  overflow-y: scroll;
  scrollbar-width: none;
  -ms-overflow-style: none;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  z-index: 1000;
}

/* 隐藏WebKit浏览器(Chrome, Safari)的滚动条 */
.sidebar::-webkit-scrollbar {
  display: none;
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