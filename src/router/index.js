import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue'; // 导入你的当前页面组件
import Chat from '../views/Chat.vue';
import Register from '../views/Register.vue'
import Welcome from '../views/Welcome.vue'; // 导入新的欢迎页组件
import Files from '@/views/Files.vue'

// 导入管理系统布局组件
import AdminLayout from '../views/admin/AdminLayout.vue';
import AdminDashboard from '../views/admin/AdminDashboard.vue';

const routes = [
    {
        path: '/', // 根路径设置为欢迎页
        name: 'welcome',
        component: Welcome, // 使用欢迎页作为真正的首页
    },
    {
        path: '/chat',
        name: 'chat',
        component: Chat,
    },
    {
        path: '/login',
        name: 'Login',
        component: Login,
    },
    {
        path: '/register',
        name: 'Register',
        component: Register,
    },
    {
        path: '/files',
        name: 'Files',
        component: Files,
        meta: {
            title: '安全资料库 - 化工安全AI助手'
        }
    },
    // 管理系统路由
    {
        path: '/admin',
        component: AdminLayout,
        redirect: '/admin/dashboard',
        children: [
            {
                path: 'dashboard',
                name: 'AdminDashboard',
                component: AdminDashboard,
                meta: { title: '管理系统控制台', requiresAdmin: true }
            },
            // 系统监控
            {
                path: 'monitor/conversation',
                name: 'ConversationStats',
                component: () => import('../components/admin/monitor/ConversationStats.vue'),
                meta: { title: '对话数据统计', requiresAdmin: true }
            },
            {
                path: 'monitor/users',
                name: 'UserActivity',
                component: () => import('../components/admin/monitor/UserActivity.vue'),
                meta: { title: '用户活跃度监控', requiresAdmin: true }
            },
            // 用户管理
            {
                path: 'users/user-management',
                name: 'UserManagement',
                component: () => import('../components/admin/users/UserManagement.vue'), // 重用UserList组件或创建新的组件
                meta: { title: '用户查询与管理', requiresAdmin: true }
            },
            {
                path: 'users/login-history',
                name: 'LoginHistory',
                component: () => import('../components/admin/users/LoginHistory.vue'),
                meta: { title: '用户登录历史', requiresAdmin: true }
            },
            // 管理员管理
            {
                path: 'admins/admin-management',
                name: 'AdminManagement',
                component: () => import('../components/admin/admins/AdminManagement.vue'),
                meta: { title: '管理员与角色管理', requiresAdmin: true },
                alias: ['admins/list']
            },
            {
                path: 'admins/logs',
                name: 'OperationLogs',
                component: () => import('../components/admin/admins/OperationLogs.vue'),
                meta: { title: '管理员操作日志', requiresAdmin: true }
            },
            // 内容管理
            {
                path: 'content/categories',
                name: 'CategoryManager',
                component: () => import('../components/admin/content/CategoryManager.vue'),
                meta: { title: '知识库分类管理', requiresAdmin: true }
            },
            {
                path: 'content/documents',
                name: 'DocumentManager',
                component: () => import('../components/admin/content/DocumentManager.vue'),
                meta: { title: '知识文档管理', requiresAdmin: true }
            },
            {
                path: 'content/emergency',
                name: 'EmergencyPlanManager',
                component: () => import('../components/admin/content/EmergencyPlanManager.vue'),
                meta: { title: '应急处理方案管理', requiresAdmin: true }
            },
            {
                path: 'content/review',
                name: 'ContentReview',
                component: () => import('../components/admin/content/ContentReview.vue'),
                meta: { title: '内容审核机制', requiresAdmin: true }
            },
            // 反馈管理
            {
                path: 'feedback/list',
                name: 'FeedbackList',
                component: () => import('../components/admin/feedback/FeedbackList.vue'),
                meta: { title: '用户反馈列表', requiresAdmin: true }
            },
            {
                path: 'feedback/statistics',
                name: 'FeedbackStats',
                component: () => import('../components/admin/feedback/FeedbackStats.vue'),
                meta: { title: '反馈分类统计', requiresAdmin: true }
            },
            {
                path: 'feedback/status',
                name: 'FeedbackStatus',
                component: () => import('../components/admin/feedback/FeedbackStatus.vue'),
                meta: { title: '反馈处理状态管理', requiresAdmin: true }
            },
            {
                path: 'feedback/ratings',
                name: 'ContentRating',
                component: () => import('../components/admin/feedback/ContentRating.vue'),
                meta: { title: '内容评价分析', requiresAdmin: true }
            },
            // 系统设置
            {
                path: 'settings/ai-model',
                name: 'AIModelConfig',
                component: () => import('../components/admin/settings/AIModelConfig.vue'),
                meta: { title: 'AI模型配置', requiresAdmin: true }
            },
            {
                path: 'settings/system-params',
                name: 'SystemParams',
                component: () => import('../components/admin/settings/SystemParams.vue'),
                meta: { title: '系统参数设置', requiresAdmin: true }
            },
            {
                path: 'settings/registration',
                name: 'RegistrationStrategy',
                component: () => import('../components/admin/settings/RegistrationStrategy.vue'),
                meta: { title: '用户注册策略', requiresAdmin: true }
            }
        ]
    },
    // 可以继续添加其他路由...
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

// 路由守卫，检查管理员权限
router.beforeEach((to, from, next) => {
    if (to.matched.some(record => record.meta.requiresAdmin)) {
        // 检查是否为管理员
        const isAdmin = localStorage.getItem('isAdmin') === 'true';
        if (!isAdmin) {
            next('/login'); // 如果不是管理员，则跳转到登录页
        } else {
            next(); // 是管理员，允许访问
        }
    } else {
        next(); // 不需要管理员权限的页面，直接放行
    }
});

export default router;