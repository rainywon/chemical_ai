/*
化工安全AI助手系统数据库设计

设计思路:
1. 用户管理: 
   - 用户可以通过手机号和验证码或密码登录
   - 支持用户注册和身份验证
   - 存储用户的主题偏好设置

2. 聊天功能:
   - 存储用户与AI之间的对话历史
   - 每个聊天可以包含多条消息
   - 聊天可以有不同的主题和类型

3. 反馈系统:
   - 用户可以提交反馈，包括不同类型的反馈（功能建议、问题反馈等）
   - 反馈需要包含详细内容和评分

4. 知识库:
   - 存储化工安全相关的文档和资料
   - 分类管理各种安全资料和指南

5. 系统状态:
   - 记录系统状态、版本和更新信息
*/

-- 创建数据库
CREATE DATABASE IF NOT EXISTS chemical_ai_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE chemical_ai_db;

-- 用户表
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    mobile VARCHAR(15) NOT NULL UNIQUE COMMENT '用户手机号',
    password VARCHAR(255) COMMENT '加密后的密码',
    theme_preference ENUM('light', 'dark') DEFAULT 'light' COMMENT '主题偏好',
    register_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    last_login_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '最后登录时间',
    status TINYINT DEFAULT 1 COMMENT '账号状态: 0-禁用, 1-正常',
    INDEX idx_mobile (mobile)
) COMMENT='用户信息表';

-- 验证码表
CREATE TABLE verification_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mobile VARCHAR(15) NOT NULL COMMENT '手机号',
    code VARCHAR(6) NOT NULL COMMENT '验证码',
    purpose ENUM('login', 'register', 'reset_password') NOT NULL COMMENT '用途',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    expire_at DATETIME NOT NULL COMMENT '过期时间',
    is_used TINYINT DEFAULT 0 COMMENT '是否已使用: 0-未使用, 1-已使用',
    INDEX idx_mobile_purpose (mobile, purpose)
) COMMENT='验证码表';

-- 用户登录令牌表
CREATE TABLE user_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT '用户ID',
    token VARCHAR(255) NOT NULL COMMENT '登录令牌',
    device_info VARCHAR(255) DEFAULT NULL COMMENT '设备信息',
    ip_address VARCHAR(45) DEFAULT NULL COMMENT 'IP地址',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    expire_at DATETIME NOT NULL COMMENT '过期时间',
    is_valid TINYINT DEFAULT 1 COMMENT '是否有效: 0-无效, 1-有效',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY (token),
    INDEX idx_user_id (user_id)
) COMMENT='用户登录令牌表';


-- AI模型配置表
CREATE TABLE ai_models (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(50) NOT NULL COMMENT '模型名称',
    model_version VARCHAR(20) NOT NULL COMMENT '模型版本',
    description TEXT DEFAULT NULL COMMENT '模型描述',
    is_active TINYINT DEFAULT 1 COMMENT '是否激活: 0-禁用, 1-激活',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='AI模型配置表';

-- 反馈类型表
CREATE TABLE feedback_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL COMMENT '类型名称',
    type_code VARCHAR(20) NOT NULL UNIQUE COMMENT '类型编码',
    icon VARCHAR(50) DEFAULT NULL COMMENT '图标',
    description VARCHAR(255) DEFAULT NULL COMMENT '描述',
    sort_order INT DEFAULT 0 COMMENT '排序顺序'
) COMMENT='反馈类型表';

-- 插入默认反馈类型
INSERT INTO feedback_types (type_name, type_code, icon, description, sort_order) VALUES 
('功能建议', 'suggestion', '💡', '对系统功能的建议和意见', 1),
('问题反馈', 'bug', '🐛', '系统问题和错误反馈', 2),
('内容改进', 'content', '📝', '对内容的改进建议', 3),
('其他', 'other', '✨', '其他类型的反馈', 4);

-- 用户反馈表
CREATE TABLE user_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL COMMENT '用户ID，允许匿名反馈',
    feedback_type VARCHAR(20) NOT NULL COMMENT '反馈类型',
    feedback_content TEXT NOT NULL COMMENT '反馈内容',
    rating INT DEFAULT NULL COMMENT '评分(1-5)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    status ENUM('pending', 'processing', 'resolved', 'rejected') DEFAULT 'pending' COMMENT '处理状态',
    admin_reply TEXT DEFAULT NULL COMMENT '管理员回复',
    replied_at DATETIME DEFAULT NULL COMMENT '回复时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_feedback_type (feedback_type),
    INDEX idx_created_at (created_at)
) COMMENT='用户反馈表';

-- 知识库分类表
CREATE TABLE knowledge_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL COMMENT '分类名称',
    parent_id INT DEFAULT NULL COMMENT '父分类ID',
    icon VARCHAR(50) DEFAULT NULL COMMENT '图标',
    description VARCHAR(255) DEFAULT NULL COMMENT '分类描述',
    sort_order INT DEFAULT 0 COMMENT '排序顺序',
    FOREIGN KEY (parent_id) REFERENCES knowledge_categories(category_id) ON DELETE SET NULL,
    INDEX idx_parent_id (parent_id)
) COMMENT='知识库分类表';

-- 插入默认分类
INSERT INTO knowledge_categories (category_name, parent_id, icon, description, sort_order) VALUES 
('安全手册', NULL, '📕', '化工安全操作手册', 1),
('标准文件', NULL, '📃', '行业标准和规范文档', 2),
('危化品MSDS', NULL, '☢️', '危险化学品安全技术说明书', 3);

-- 知识库文档表
CREATE TABLE knowledge_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL COMMENT '分类ID',
    title VARCHAR(100) NOT NULL COMMENT '文档标题',
    file_path VARCHAR(255) NOT NULL COMMENT '文件路径',
    file_size INT DEFAULT 0 COMMENT '文件大小(KB)',
    file_type VARCHAR(20) DEFAULT NULL COMMENT '文件类型',
    author VARCHAR(50) DEFAULT NULL COMMENT '作者',
    publish_date DATE DEFAULT NULL COMMENT '发布日期',
    description TEXT DEFAULT NULL COMMENT '文档描述',
    is_published TINYINT DEFAULT 1 COMMENT '是否发布: 0-未发布, 1-已发布',
    view_count INT DEFAULT 0 COMMENT '查看次数',
    download_count INT DEFAULT 0 COMMENT '下载次数',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (category_id) REFERENCES knowledge_categories(category_id) ON DELETE CASCADE,
    INDEX idx_category_id (category_id),
    INDEX idx_title (title)
) COMMENT='知识库文档表';

-- 应急处理方案表
CREATE TABLE emergency_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_type ENUM('fire', 'leak', 'poison', 'other') NOT NULL COMMENT '应急类型',
    title VARCHAR(100) NOT NULL COMMENT '方案标题',
    content TEXT NOT NULL COMMENT '方案内容',
    is_published TINYINT DEFAULT 1 COMMENT '是否发布: 0-未发布, 1-已发布',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_plan_type (plan_type)
) COMMENT='应急处理方案表';

-- 系统版本表
CREATE TABLE system_versions (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    version_number VARCHAR(20) NOT NULL COMMENT '版本号',
    knowledge_base_version VARCHAR(20) DEFAULT NULL COMMENT '知识库版本',
    release_date DATE NOT NULL COMMENT '发布日期',
    update_notes TEXT DEFAULT NULL COMMENT '更新说明',
    is_current TINYINT DEFAULT 0 COMMENT '是否当前版本: 0-否, 1-是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) COMMENT='系统版本表';

-- 插入初始版本数据
INSERT INTO system_versions (version_number, knowledge_base_version, release_date, update_notes, is_current)
VALUES ('1.0.0', 'v3.2.1', CURDATE(), '化工安全AI助手系统初始版本', 1);

-- 系统配置表
CREATE TABLE system_configs (
    config_id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(50) NOT NULL UNIQUE COMMENT '配置键',
    config_value TEXT NOT NULL COMMENT '配置值',
    description VARCHAR(255) DEFAULT NULL COMMENT '配置描述',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='系统配置表';

-- 插入一些默认配置
INSERT INTO system_configs (config_key, config_value, description) VALUES
('knowledge_base_update_date', '2023-12-15', '知识库最后更新日期'),
('data_sources_count', '32', '知识库数据源数量'),
('response_time_limit', '2', '系统响应时间限制(秒)'),
('system_status', 'normal', '系统运行状态: normal-正常, maintenance-维护中, error-错误');

-- 管理员表
CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '管理员用户名',
    password VARCHAR(255) NOT NULL COMMENT '加密后的密码',
    full_name VARCHAR(100) DEFAULT NULL COMMENT '管理员姓名',
    role ENUM('super_admin', 'admin', 'operator') NOT NULL DEFAULT 'operator' COMMENT '角色类型',
    email VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    mobile VARCHAR(15) DEFAULT NULL COMMENT '手机号',
    status TINYINT DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
    last_login_time DATETIME DEFAULT NULL COMMENT '最后登录时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_role (role)
) COMMENT='管理员表';

-- 操作日志表
CREATE TABLE operation_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL COMMENT '用户ID',
    admin_id INT DEFAULT NULL COMMENT '管理员ID',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_desc TEXT NOT NULL COMMENT '操作描述',
    ip_address VARCHAR(45) DEFAULT NULL COMMENT 'IP地址',
    user_agent VARCHAR(255) DEFAULT NULL COMMENT '用户代理',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_admin_id (admin_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_created_at (created_at)
) COMMENT='操作日志表';

/*
数据库关系说明:

1. 用户管理:
   - users表存储用户基本信息
   - verification_codes表与users表关联，存储验证码
   - user_tokens表与users表关联，存储登录令牌

2. 聊天功能:
   - chat_conversations表与users表关联，存储聊天会话
   - chat_messages表与chat_conversations表关联，存储具体消息

3. 反馈系统:
   - feedback_types表存储反馈类型
   - user_feedback表与users表关联，存储用户反馈

4. 知识库:
   - knowledge_categories表存储分类，支持自关联实现多层分类
   - knowledge_documents表与knowledge_categories表关联，存储文档
   - emergency_plans表存储应急处理方案

5. 系统配置:
   - system_versions表存储系统版本信息
   - system_configs表存储系统配置
   - admins表存储管理员信息
   - operation_logs表记录系统操作日志

索引设计主要考虑:
1. 主键索引 - 每个表的主键
2. 外键索引 - 关联字段创建索引提高查询效率
3. 常用查询条件索引 - 如手机号、创建时间等经常用于检索的字段
*/ 