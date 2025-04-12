<template>
  <div class="login-history-container">
    <h1 class="text-h5 mb-4">用户登录历史</h1>
    
    <!-- 搜索过滤区域 -->
    <v-card class="mb-4 pa-3">
      <v-row>
        <v-col cols="12" sm="3">
          <v-text-field
            v-model="searchParams.userId"
            label="用户ID"
            type="number"
            clearable
            outlined
            dense
          ></v-text-field>
        </v-col>
        <v-col cols="12" sm="3">
          <v-text-field
            v-model="searchParams.mobile"
            label="手机号"
            clearable
            outlined
            dense
          ></v-text-field>
        </v-col>
        <v-col cols="12" sm="3">
          <v-menu
            ref="startDateMenu"
            v-model="startDateMenu"
            :close-on-content-click="false"
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="searchParams.startDate"
                label="起始日期"
                readonly
                outlined
                dense
                clearable
                v-bind="attrs"
                v-on="on"
                @click:clear="searchParams.startDate = null"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="searchParams.startDate"
              @input="startDateMenu = false"
            ></v-date-picker>
          </v-menu>
        </v-col>
        <v-col cols="12" sm="3">
          <v-menu
            ref="endDateMenu"
            v-model="endDateMenu"
            :close-on-content-click="false"
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="searchParams.endDate"
                label="结束日期"
                readonly
                outlined
                dense
                clearable
                v-bind="attrs"
                v-on="on"
                @click:clear="searchParams.endDate = null"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="searchParams.endDate"
              @input="endDateMenu = false"
            ></v-date-picker>
          </v-menu>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="text-right">
          <v-btn color="primary" @click="searchLoginHistory">
            <v-icon left>mdi-magnify</v-icon>
            搜索
          </v-btn>
          <v-btn
            class="ml-2"
            outlined
            color="grey"
            @click="resetSearchParams"
          >
            <v-icon left>mdi-refresh</v-icon>
            重置
          </v-btn>
        </v-col>
      </v-row>
    </v-card>

    <!-- 登录历史表格 -->
    <v-card>
      <v-data-table
        :headers="headers"
        :items="loginHistory"
        :loading="loading"
        :items-per-page="pageSize"
        :server-items-length="totalItems"
        :page.sync="currentPage"
        :options.sync="options"
        @update:options="fetchLoginHistory"
        class="elevation-1"
      >
        <template v-slot:item.status="{ item }">
          <v-chip
            small
            :color="item.status === '有效' ? 'success' : 'error'"
            text-color="white"
          >
            {{ item.status }}
          </v-chip>
        </template>

        <template v-slot:item.actions="{ item }">
          <v-btn
            small
            text
            color="primary"
            @click="viewUserDetails(item.user_id)"
          >
            <v-icon small>mdi-account-details</v-icon>
            用户详情
          </v-btn>
        </template>

        <template v-slot:no-data>
          <div class="text-center pa-5">
            <v-icon large color="grey">mdi-database-off</v-icon>
            <div class="mt-2 grey--text">暂无登录记录</div>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- 用户详情对话框 -->
    <v-dialog v-model="userDialogVisible" max-width="600px">
      <v-card v-if="selectedUser">
        <v-card-title class="headline">
          用户详情 (ID: {{ selectedUser.user_id }})
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col cols="6">
              <v-text-field
                label="手机号"
                :value="selectedUser.mobile"
                readonly
                outlined
                dense
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                label="用户名"
                :value="selectedUser.username || '未设置'"
                readonly
                outlined
                dense
              ></v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="6">
              <v-text-field
                label="注册时间"
                :value="selectedUser.created_at"
                readonly
                outlined
                dense
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                label="最后登录"
                :value="selectedUser.last_login || '未记录'"
                readonly
                outlined
                dense
              ></v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="6">
              <v-text-field
                label="账户状态"
                :value="selectedUser.status === 1 ? '正常' : '禁用'"
                readonly
                outlined
                dense
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                label="用户类型"
                :value="selectedUser.role === 'admin' ? '管理员' : '普通用户'"
                readonly
                outlined
                dense
              ></v-text-field>
            </v-col>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="userDialogVisible = false">
            关闭
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'LoginHistory',
  data() {
    return {
      // 搜索参数
      searchParams: {
        userId: null,
        mobile: null,
        startDate: null,
        endDate: null
      },
      // 日期选择器状态
      startDateMenu: false,
      endDateMenu: false,
      // 表格相关
      loading: false,
      headers: [
        { text: 'ID', value: 'id', align: 'start' },
        { text: '用户ID', value: 'user_id', align: 'start' },
        { text: '手机号', value: 'mobile', align: 'start' },
        { text: '登录时间', value: 'login_time', align: 'start' },
        { text: '登录状态', value: 'status', align: 'start' },
        { text: '过期时间', value: 'expire_at', align: 'start' },
        { text: '设备信息', value: 'device_info', align: 'start' },
        { text: 'IP地址', value: 'ip_address', align: 'start' },
        { text: '操作', value: 'actions', sortable: false, align: 'center' }
      ],
      loginHistory: [],
      totalItems: 0,
      currentPage: 1,
      pageSize: 10,
      options: {},
      // 用户详情相关
      userDialogVisible: false,
      selectedUser: null
    }
  },
  mounted() {
    this.fetchLoginHistory()
  },
  methods: {
    // 获取登录历史记录
    async fetchLoginHistory() {
      this.loading = true
      try {
        // 根据选项构建查询参数
        if (this.options.page) {
          this.currentPage = this.options.page
        }
        if (this.options.itemsPerPage) {
          this.pageSize = this.options.itemsPerPage
        }

        // 构建参数
        const params = {
          page: this.currentPage,
          page_size: this.pageSize
        }

        // 添加筛选条件
        if (this.searchParams.userId) {
          params.user_id = this.searchParams.userId
        }
        if (this.searchParams.mobile) {
          params.mobile = this.searchParams.mobile
        }
        if (this.searchParams.startDate) {
          params.start_date = this.searchParams.startDate
        }
        if (this.searchParams.endDate) {
          params.end_date = this.searchParams.endDate
        }

        // 发送请求获取登录历史
        const response = await axios.get('/api/admin/users/login-history', { params })
        
        if (response.data.code === 200) {
          this.loginHistory = response.data.data.logins
          this.totalItems = response.data.data.total
        } else {
          this.$toast.error(`获取登录历史失败: ${response.data.message}`)
        }
      } catch (error) {
        console.error('获取登录历史失败:', error)
        this.$toast.error(`获取登录历史失败: ${error.message || '服务器错误'}`)
      } finally {
        this.loading = false
      }
    },
    // 搜索登录历史
    searchLoginHistory() {
      this.currentPage = 1
      this.fetchLoginHistory()
    },
    // 重置搜索参数
    resetSearchParams() {
      this.searchParams = {
        userId: null,
        mobile: null,
        startDate: null,
        endDate: null
      }
      this.currentPage = 1
      this.fetchLoginHistory()
    },
    // 查看用户详情
    async viewUserDetails(userId) {
      this.loading = true
      try {
        const response = await axios.get(`/api/admin/users/${userId}`)
        
        if (response.data.code === 200) {
          this.selectedUser = response.data.data
          this.userDialogVisible = true
        } else {
          this.$toast.error(`获取用户详情失败: ${response.data.message}`)
        }
      } catch (error) {
        console.error('获取用户详情失败:', error)
        this.$toast.error(`获取用户详情失败: ${error.message || '服务器错误'}`)
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.login-history-container {
  padding: 16px;
}
</style> 