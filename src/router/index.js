import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue'; // 导入你的当前页面组件
import Chat from '../views/Chat.vue';
import Register from '../views/Register.vue'
import Welcome from '../views/Welcome.vue'; // 导入新的欢迎页组件
import Files from '@/views/Files.vue'

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
    // 可以继续添加其他路由...
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;