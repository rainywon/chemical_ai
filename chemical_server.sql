/*
 Navicat Premium Data Transfer

 Source Server         : host
 Source Server Type    : MySQL
 Source Server Version : 80034
 Source Host           : localhost:3306
 Source Schema         : chemical_server

 Target Server Type    : MySQL
 Target Server Version : 80034
 File Encoding         : 65001

 Date: 14/04/2025 18:55:28
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_tokens
-- ----------------------------
DROP TABLE IF EXISTS `admin_tokens`;
CREATE TABLE `admin_tokens`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL COMMENT '管理员ID',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录令牌',
  `device_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备信息',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `expire_at` datetime NOT NULL COMMENT '过期时间',
  `is_valid` tinyint NULL DEFAULT 1 COMMENT '是否有效: 0-无效, 1-有效',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token`(`token` ASC) USING BTREE,
  INDEX `idx_admin_id`(`admin_id` ASC) USING BTREE,
  CONSTRAINT `admin_tokens_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`admin_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员登录令牌表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_tokens
-- ----------------------------

-- ----------------------------
-- Table structure for admins
-- ----------------------------
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins`  (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '管理员手机号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加密后的密码',
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员姓名',
  `role` enum('admin','operator') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'operator' COMMENT '角色类型',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`admin_id`) USING BTREE,
  UNIQUE INDEX `username`(`phone_number` ASC) USING BTREE,
  INDEX `idx_username`(`phone_number` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES (1, '18350191687', 'c412e04cf954373dfea8db43c5984438', '吴凯歌', 'admin', '1028418330@qq.com', 1, '2025-04-14 14:27:03', '2025-04-12 14:52:07', '2025-04-14 16:44:47');

-- ----------------------------
-- Table structure for ai_models
-- ----------------------------
DROP TABLE IF EXISTS `ai_models`;
CREATE TABLE `ai_models`  (
  `model_id` int NOT NULL AUTO_INCREMENT,
  `model_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型名称',
  `model_version` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型版本',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '模型描述',
  `is_active` tinyint NULL DEFAULT 1 COMMENT '是否激活: 0-禁用, 1-激活',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`model_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI模型配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_models
-- ----------------------------

-- ----------------------------
-- Table structure for chat_messages
-- ----------------------------
DROP TABLE IF EXISTS `chat_messages`;
CREATE TABLE `chat_messages`  (
  `id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `session_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `message_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `parent_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `paired_ai_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `message_references` json NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `is_loading` tinyint(1) NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_session_id`(`session_id` ASC) USING BTREE,
  CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `chat_sessions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_messages
-- ----------------------------
INSERT INTO `chat_messages` VALUES ('1744440370894', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'user', '粉尘治理怎么做\n', NULL, '1744440370895', '[]', NULL, 0, '2025-04-12 14:46:10');
INSERT INTO `chat_messages` VALUES ('1744440370895', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'ai', '<think>\n【问题分析】\n1. 核心安全风险：粉尘爆炸、粉尘窒息、中毒等\n2. 相关法规标准：GB/T 16297-2006《工作场所职业病危害因素分类与代码》、AQ 3009-2007《化工企业粉尘防爆安全规范》\n3. 可能原因：粉尘产生源、粉尘收集不良、通风不足、设备维护不当等\n4. 误操作后果：可能导致人员伤亡、财产损失和环境污染\n\n【解决思路】\n- 分步骤展开解决方案\n- 比较不同方法的优缺点\n- 结合最新行业案例\n- 特殊情况的应急处理\n</think>\n\n【专业回答】\n<|im_start|>system\n1. **立即行动方案（带编号步骤）**：\n   (1) 立即停止产生粉尘的作业，并关闭相关设备。\n   (2) 对现场进行通风，确保空气流通。\n   (3) 使用防爆工具和个人防护装备进行紧急清理。\n\n2. **根本原因排查（检查清单）**：\n   √ 检查粉尘产生源的设备是否正常运行。\n   √ 评估现有粉尘收集系统的效率。\n   √ 检查通风系统是否有效。\n   √ 检查设备维护记录，确保定期维护。\n\n3. **长期预防措施**：\n   - 定期对粉尘收集系统进行清洁和维护。\n   - 安装高效的粉尘过滤器。\n   - 实施严格的通风管理计划。\n   - 对员工进行粉尘危害意识培训。\n\n4. **培训建议**：\n   * 定期组织粉尘安全培训，提高员工对粉尘危害的认识。\n   * 培训员工正确使用个人防护装备和紧急疏散程序。\n   * 强调在高风险区域工作时必须佩戴防爆服。\n\n', '1744440370894', NULL, '[]', '粉尘治理怎么做\n', 0, '2025-04-12 14:46:10');
INSERT INTO `chat_messages` VALUES ('1744440383290', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'user', '粉尘治理怎么做', NULL, '1744440383291', '[]', NULL, 0, '2025-04-12 14:46:23');
INSERT INTO `chat_messages` VALUES ('1744440383291', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'ai', '', '1744440383290', NULL, '[]', '粉尘治理怎么做', 1, '2025-04-12 14:46:23');
INSERT INTO `chat_messages` VALUES ('1744440404702', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'user', '粉尘治理怎么做', NULL, '1744440404703', '[]', NULL, 0, '2025-04-12 14:46:45');
INSERT INTO `chat_messages` VALUES ('1744440404703', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'ai', '<think>\n【问题分析】\n1. 核心安全风险：粉尘爆炸、粉尘中毒、粉尘火灾等。\n2. 相关法规标准：GB/T 16297《工作场所职业病危害因素分类与代码》、AQ 3009《化工企业粉尘防爆安全规范》。\n3. 可能原因：粉尘产生源、粉尘收集不良、粉尘清理不及时等。\n\n【解决思路】\n- 分步骤展开解决方案\n- 比较不同方法的优缺点\n- 结合最新行业案例\n- 特殊情况的应急处理\n</think>\n\n【专业回答】\n<|im_start|>\n1. **立即行动方案（带编号步骤）**\n   (1) 立即对粉尘源进行隔离，防止粉尘扩散。\n   (2) 对工作场所进行通风，降低粉尘浓度。\n   (3) 对受影响区域进行风险评估，确保人员安全撤离。\n\n2. **根本原因排查（检查清单）**\n   √ 检查粉尘产生设备是否正常运行\n   √ 确认粉尘收集系统是否有效\n   √ 检查粉尘清理系统的工作状态\n\n3. **长期预防措施**\n   - 定期对粉尘收集和排放系统进行维护保养。\n   - 安装粉尘检测仪，实时监控粉尘浓度。\n   - 对员工进行粉尘危害意识培训。\n\n4. **应急处理方案**\n   - 在粉尘浓度超标时，立即启动应急预案。\n   - 使用防爆设备和防护装备进行清理工作。\n   - 设置隔离区域，防止无关人员进入。\n\n', '1744440404702', NULL, '[]', '粉尘治理怎么做', 0, '2025-04-12 14:46:45');
INSERT INTO `chat_messages` VALUES ('1744440494401', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'user', '你能做什么\n', NULL, '1744440494402', '[]', NULL, 0, '2025-04-12 14:48:14');
INSERT INTO `chat_messages` VALUES ('1744440494402', '3ad1b243-41c0-4a2b-aee7-d9772300d832', 'ai', '<think>\n我是DeepSeek-R1，一个由深度求索公司开发的智能助手，我擅长通过思考来帮您解答复杂的数学、代码和逻辑推理等问题。如果你有任何问题，随时可以告诉我！\n', '1744440494401', NULL, '[]', '你能做什么\n', 0, '2025-04-12 14:48:14');

-- ----------------------------
-- Table structure for chat_sessions
-- ----------------------------
DROP TABLE IF EXISTS `chat_sessions`;
CREATE TABLE `chat_sessions`  (
  `id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `user_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_sessions
-- ----------------------------
INSERT INTO `chat_sessions` VALUES ('3ad1b243-41c0-4a2b-aee7-d9772300d832', '13', '粉尘治理怎么做', '2025-04-12 14:46:10', '2025-04-12 14:48:14');

-- ----------------------------
-- Table structure for content_feedbacks
-- ----------------------------
DROP TABLE IF EXISTS `content_feedbacks`;
CREATE TABLE `content_feedbacks`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户id',
  `rating` int NOT NULL COMMENT '星级评分',
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '反馈内容',
  `feedback_option` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '反馈选项',
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'AI回答内容',
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户问题',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `status` enum('pending','processing','resolved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `admin_reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `replied_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '内容反馈表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of content_feedbacks
-- ----------------------------
INSERT INTO `content_feedbacks` VALUES (1, 13, 3, '修改一下\n', 'incomplete', '<think>\n我是DeepSeek-R1，一个由深度求索公司开发的智能助手，我擅长通过思考来帮您解答复杂的数学、代码和逻辑推理等问题。如果你有任何问题，随时可以告诉我！\n', '你能做什么\n', '2025-04-14 13:08:40', 'pending', NULL, NULL);
INSERT INTO `content_feedbacks` VALUES (2, 13, 4, '修改一下', 'incomplete', '<think>\n我是DeepSeek-R1，一个由深度求索公司开发的智能助手，我擅长通过思考来帮您解答复杂的数学、代码和逻辑推理等问题。如果你有任何问题，随时可以告诉我！\n', '你能做什么\n', '2025-04-14 13:12:15', 'pending', NULL, NULL);
INSERT INTO `content_feedbacks` VALUES (3, 13, 2, '不好', 'incomplete', '<think>\n我是DeepSeek-R1，一个由深度求索公司开发的智能助手，我擅长通过思考来帮您解答复杂的数学、代码和逻辑推理等问题。如果你有任何问题，随时可以告诉我！\n', '你能做什么\n', '2025-04-14 13:12:46', 'pending', NULL, NULL);

-- ----------------------------
-- Table structure for emergency_plans
-- ----------------------------
DROP TABLE IF EXISTS `emergency_plans`;
CREATE TABLE `emergency_plans`  (
  `plan_id` int NOT NULL AUTO_INCREMENT,
  `plan_type` enum('fire','leak','poison','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应急类型',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '方案标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '方案内容',
  `is_published` tinyint NULL DEFAULT 1 COMMENT '是否发布: 0-未发布, 1-已发布',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`plan_id`) USING BTREE,
  INDEX `idx_plan_type`(`plan_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '应急处理方案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of emergency_plans
-- ----------------------------

-- ----------------------------
-- Table structure for feedback_types
-- ----------------------------
DROP TABLE IF EXISTS `feedback_types`;
CREATE TABLE `feedback_types`  (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `type_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型名称',
  `type_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型编码',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序顺序',
  PRIMARY KEY (`type_id`) USING BTREE,
  UNIQUE INDEX `type_code`(`type_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '反馈类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of feedback_types
-- ----------------------------
INSERT INTO `feedback_types` VALUES (1, '功能建议', 'suggestion', '💡', '对系统功能的建议和意见', 1);
INSERT INTO `feedback_types` VALUES (2, '问题反馈', 'bug', '🐛', '系统问题和错误反馈', 2);
INSERT INTO `feedback_types` VALUES (3, '内容改进', 'content', '📝', '对内容的改进建议', 3);
INSERT INTO `feedback_types` VALUES (4, '其他', 'other', '✨', '其他类型的反馈', 4);

-- ----------------------------
-- Table structure for knowledge_categories
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_categories`;
CREATE TABLE `knowledge_categories`  (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `parent_id` int NULL DEFAULT NULL COMMENT '父分类ID',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类描述',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序顺序',
  PRIMARY KEY (`category_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `knowledge_categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `knowledge_categories` (`category_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of knowledge_categories
-- ----------------------------
INSERT INTO `knowledge_categories` VALUES (1, '安全手册', NULL, '📕', '化工安全操作手册', 1);
INSERT INTO `knowledge_categories` VALUES (2, '标准文件', NULL, '📃', '行业标准和规范文档', 2);
INSERT INTO `knowledge_categories` VALUES (3, '危化品MSDS', NULL, '☢️', '危险化学品安全技术说明书', 3);

-- ----------------------------
-- Table structure for knowledge_documents
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_documents`;
CREATE TABLE `knowledge_documents`  (
  `document_id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL COMMENT '分类ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文档标题',
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件路径',
  `file_size` int NULL DEFAULT 0 COMMENT '文件大小(KB)',
  `file_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件类型',
  `author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '作者',
  `publish_date` date NULL DEFAULT NULL COMMENT '发布日期',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '文档描述',
  `is_published` tinyint NULL DEFAULT 1 COMMENT '是否发布: 0-未发布, 1-已发布',
  `view_count` int NULL DEFAULT 0 COMMENT '查看次数',
  `download_count` int NULL DEFAULT 0 COMMENT '下载次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`document_id`) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE,
  CONSTRAINT `knowledge_documents_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `knowledge_categories` (`category_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库文档表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of knowledge_documents
-- ----------------------------

-- ----------------------------
-- Table structure for operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `admin_id` int NULL DEFAULT NULL COMMENT '管理员ID',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型',
  `operation_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作描述',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户代理',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_admin_id`(`admin_id` ASC) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `operation_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `operation_logs_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`admin_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operation_logs
-- ----------------------------
INSERT INTO `operation_logs` VALUES (45, NULL, 1, '查询', '管理员1预览了文件[AQ 016—008]含硫化氢天然气井失控井口点火时间规定.xlsx', NULL, NULL, '2025-04-14 12:17:25');
INSERT INTO `operation_logs` VALUES (46, NULL, 1, '下载文件', '管理员1下载了文件[AQ 016—008]含硫化氢天然气井失控井口点火时间规定.xlsx', NULL, NULL, '2025-04-14 12:17:27');
INSERT INTO `operation_logs` VALUES (47, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:17:39');
INSERT INTO `operation_logs` VALUES (48, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:17:45');
INSERT INTO `operation_logs` VALUES (49, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:17:59');
INSERT INTO `operation_logs` VALUES (50, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:18:03');
INSERT INTO `operation_logs` VALUES (51, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:18:05');
INSERT INTO `operation_logs` VALUES (52, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:18:07');
INSERT INTO `operation_logs` VALUES (53, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:18:08');
INSERT INTO `operation_logs` VALUES (54, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:18:08');
INSERT INTO `operation_logs` VALUES (55, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:18:09');
INSERT INTO `operation_logs` VALUES (56, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:18:09');
INSERT INTO `operation_logs` VALUES (57, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 12:18:10');
INSERT INTO `operation_logs` VALUES (58, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 12:18:10');
INSERT INTO `operation_logs` VALUES (59, NULL, NULL, 'admin_login', '管理员登录系统', NULL, NULL, '2025-04-14 12:37:34');
INSERT INTO `operation_logs` VALUES (60, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:37:42');
INSERT INTO `operation_logs` VALUES (61, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:37:51');
INSERT INTO `operation_logs` VALUES (62, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:39:56');
INSERT INTO `operation_logs` VALUES (63, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:39:59');
INSERT INTO `operation_logs` VALUES (64, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:40:00');
INSERT INTO `operation_logs` VALUES (65, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 12:40:01');
INSERT INTO `operation_logs` VALUES (66, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:40:02');
INSERT INTO `operation_logs` VALUES (67, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:40:03');
INSERT INTO `operation_logs` VALUES (68, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:40:04');
INSERT INTO `operation_logs` VALUES (69, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 12:40:04');
INSERT INTO `operation_logs` VALUES (70, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:40:09');
INSERT INTO `operation_logs` VALUES (71, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:40:09');
INSERT INTO `operation_logs` VALUES (72, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:40:13');
INSERT INTO `operation_logs` VALUES (73, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:40:14');
INSERT INTO `operation_logs` VALUES (74, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:40:15');
INSERT INTO `operation_logs` VALUES (75, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:41:23');
INSERT INTO `operation_logs` VALUES (76, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:45:09');
INSERT INTO `operation_logs` VALUES (77, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 12:45:11');
INSERT INTO `operation_logs` VALUES (78, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:45:13');
INSERT INTO `operation_logs` VALUES (79, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:45:13');
INSERT INTO `operation_logs` VALUES (80, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:51:43');
INSERT INTO `operation_logs` VALUES (81, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:51:47');
INSERT INTO `operation_logs` VALUES (82, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:51:48');
INSERT INTO `operation_logs` VALUES (83, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 12:51:48');
INSERT INTO `operation_logs` VALUES (84, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:54:56');
INSERT INTO `operation_logs` VALUES (85, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:55:03');
INSERT INTO `operation_logs` VALUES (86, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 12:55:06');
INSERT INTO `operation_logs` VALUES (87, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:55:19');
INSERT INTO `operation_logs` VALUES (88, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 12:57:10');
INSERT INTO `operation_logs` VALUES (89, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 12:57:14');
INSERT INTO `operation_logs` VALUES (90, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 12:57:15');
INSERT INTO `operation_logs` VALUES (91, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:57:17');
INSERT INTO `operation_logs` VALUES (92, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 12:57:18');
INSERT INTO `operation_logs` VALUES (93, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 12:57:18');
INSERT INTO `operation_logs` VALUES (94, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 12:57:22');
INSERT INTO `operation_logs` VALUES (95, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 12:57:24');
INSERT INTO `operation_logs` VALUES (96, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 12:57:24');
INSERT INTO `operation_logs` VALUES (97, NULL, NULL, '登录', '管理员登录系统', NULL, NULL, '2025-04-14 13:13:28');
INSERT INTO `operation_logs` VALUES (98, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:13:41');
INSERT INTO `operation_logs` VALUES (99, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 13:13:41');
INSERT INTO `operation_logs` VALUES (100, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 13:13:41');
INSERT INTO `operation_logs` VALUES (101, NULL, 1, '查询', '管理员1查看AI内容反馈详情[ID:3]', NULL, NULL, '2025-04-14 13:13:49');
INSERT INTO `operation_logs` VALUES (105, NULL, NULL, '登录', '管理员登录系统', NULL, NULL, '2025-04-14 13:23:51');
INSERT INTO `operation_logs` VALUES (106, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:24:51');
INSERT INTO `operation_logs` VALUES (107, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:25:55');
INSERT INTO `operation_logs` VALUES (108, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:26:08');
INSERT INTO `operation_logs` VALUES (109, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:26:08');
INSERT INTO `operation_logs` VALUES (110, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:26:35');
INSERT INTO `operation_logs` VALUES (111, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 13:26:54');
INSERT INTO `operation_logs` VALUES (112, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 13:26:54');
INSERT INTO `operation_logs` VALUES (113, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 13:27:05');
INSERT INTO `operation_logs` VALUES (114, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 13:27:05');
INSERT INTO `operation_logs` VALUES (115, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 13:27:07');
INSERT INTO `operation_logs` VALUES (116, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 13:27:07');
INSERT INTO `operation_logs` VALUES (117, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:27:18');
INSERT INTO `operation_logs` VALUES (118, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:27:45');
INSERT INTO `operation_logs` VALUES (119, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:27:46');
INSERT INTO `operation_logs` VALUES (120, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:27:51');
INSERT INTO `operation_logs` VALUES (121, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:27:52');
INSERT INTO `operation_logs` VALUES (122, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:27:53');
INSERT INTO `operation_logs` VALUES (123, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:27:54');
INSERT INTO `operation_logs` VALUES (124, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 13:28:44');
INSERT INTO `operation_logs` VALUES (125, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:28:47');
INSERT INTO `operation_logs` VALUES (126, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:28:48');
INSERT INTO `operation_logs` VALUES (127, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:29:17');
INSERT INTO `operation_logs` VALUES (128, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:29:18');
INSERT INTO `operation_logs` VALUES (129, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 13:29:26');
INSERT INTO `operation_logs` VALUES (130, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:29:37');
INSERT INTO `operation_logs` VALUES (131, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:29:43');
INSERT INTO `operation_logs` VALUES (132, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:29:43');
INSERT INTO `operation_logs` VALUES (133, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:29:55');
INSERT INTO `operation_logs` VALUES (134, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:30:31');
INSERT INTO `operation_logs` VALUES (135, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:30:55');
INSERT INTO `operation_logs` VALUES (136, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:31:09');
INSERT INTO `operation_logs` VALUES (137, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:31:46');
INSERT INTO `operation_logs` VALUES (138, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:33:25');
INSERT INTO `operation_logs` VALUES (139, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 13:33:53');
INSERT INTO `operation_logs` VALUES (140, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 13:33:54');
INSERT INTO `operation_logs` VALUES (141, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 13:37:56');
INSERT INTO `operation_logs` VALUES (142, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:37:59');
INSERT INTO `operation_logs` VALUES (143, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:38:02');
INSERT INTO `operation_logs` VALUES (144, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 13:38:03');
INSERT INTO `operation_logs` VALUES (145, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 13:38:03');
INSERT INTO `operation_logs` VALUES (147, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:39:57');
INSERT INTO `operation_logs` VALUES (149, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 13:41:06');
INSERT INTO `operation_logs` VALUES (150, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 13:41:07');
INSERT INTO `operation_logs` VALUES (151, NULL, 1, '查询', '管理员1预览了文件[AQ 016—008]含硫化氢天然气井失控井口点火时间规定.xlsx', NULL, NULL, '2025-04-14 13:41:20');
INSERT INTO `operation_logs` VALUES (153, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 13:42:51');
INSERT INTO `operation_logs` VALUES (154, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 13:42:51');
INSERT INTO `operation_logs` VALUES (155, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 13:42:56');
INSERT INTO `operation_logs` VALUES (156, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 13:49:04');
INSERT INTO `operation_logs` VALUES (157, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 14:09:29');
INSERT INTO `operation_logs` VALUES (158, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 14:09:30');
INSERT INTO `operation_logs` VALUES (159, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 14:09:32');
INSERT INTO `operation_logs` VALUES (160, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 14:09:32');
INSERT INTO `operation_logs` VALUES (161, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 14:09:32');
INSERT INTO `operation_logs` VALUES (162, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 14:09:33');
INSERT INTO `operation_logs` VALUES (163, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 14:09:34');
INSERT INTO `operation_logs` VALUES (164, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 14:09:37');
INSERT INTO `operation_logs` VALUES (165, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 14:09:39');
INSERT INTO `operation_logs` VALUES (166, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 14:09:39');
INSERT INTO `operation_logs` VALUES (167, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 14:09:39');
INSERT INTO `operation_logs` VALUES (168, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 14:09:51');
INSERT INTO `operation_logs` VALUES (170, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 14:13:31');
INSERT INTO `operation_logs` VALUES (171, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 14:13:33');
INSERT INTO `operation_logs` VALUES (172, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 14:13:35');
INSERT INTO `operation_logs` VALUES (173, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 14:13:36');
INSERT INTO `operation_logs` VALUES (174, NULL, 1, '查询', '管理员1查询应急预案文件列表', NULL, NULL, '2025-04-14 14:15:06');
INSERT INTO `operation_logs` VALUES (175, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 14:16:51');
INSERT INTO `operation_logs` VALUES (176, NULL, NULL, '登录', '管理员登录系统', NULL, NULL, '2025-04-14 14:27:03');
INSERT INTO `operation_logs` VALUES (177, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 14:42:41');
INSERT INTO `operation_logs` VALUES (178, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 14:42:41');
INSERT INTO `operation_logs` VALUES (180, NULL, 1, '查询', '管理员1查询安全资料库文件列表', NULL, NULL, '2025-04-14 15:59:53');
INSERT INTO `operation_logs` VALUES (181, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 15:59:55');
INSERT INTO `operation_logs` VALUES (184, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 16:25:30');
INSERT INTO `operation_logs` VALUES (185, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 16:25:38');
INSERT INTO `operation_logs` VALUES (186, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 16:25:41');
INSERT INTO `operation_logs` VALUES (187, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 16:25:41');
INSERT INTO `operation_logs` VALUES (188, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 16:27:23');
INSERT INTO `operation_logs` VALUES (189, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 16:27:23');
INSERT INTO `operation_logs` VALUES (190, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 16:29:56');
INSERT INTO `operation_logs` VALUES (191, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 16:29:56');
INSERT INTO `operation_logs` VALUES (192, NULL, 1, '查询', '管理员1查询AI内容反馈列表', NULL, NULL, '2025-04-14 16:30:13');
INSERT INTO `operation_logs` VALUES (193, NULL, 1, '查询', '管理员1查询AI内容反馈统计', NULL, NULL, '2025-04-14 16:30:13');
INSERT INTO `operation_logs` VALUES (194, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 16:30:28');
INSERT INTO `operation_logs` VALUES (195, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:30');
INSERT INTO `operation_logs` VALUES (196, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:33');
INSERT INTO `operation_logs` VALUES (197, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:34');
INSERT INTO `operation_logs` VALUES (198, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:34');
INSERT INTO `operation_logs` VALUES (199, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:35');
INSERT INTO `operation_logs` VALUES (200, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:35');
INSERT INTO `operation_logs` VALUES (201, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-14 16:30:37');
INSERT INTO `operation_logs` VALUES (202, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 16:30:56');
INSERT INTO `operation_logs` VALUES (203, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 16:30:57');
INSERT INTO `operation_logs` VALUES (205, NULL, 1, '查询', '管理员1查看用户13详情', NULL, NULL, '2025-04-14 16:31:07');
INSERT INTO `operation_logs` VALUES (206, NULL, 1, '查询', '管理员1查询系统功能反馈列表', NULL, NULL, '2025-04-14 16:31:12');
INSERT INTO `operation_logs` VALUES (207, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 16:31:14');
INSERT INTO `operation_logs` VALUES (208, NULL, 1, '查询', '管理员1查询知识库文件列表', NULL, NULL, '2025-04-14 16:31:20');
INSERT INTO `operation_logs` VALUES (209, NULL, 1, '查询', '管理员1预览了文件[GB_T 9567—2016]工业用三聚氰胺.xlsx', NULL, NULL, '2025-04-14 16:31:28');
INSERT INTO `operation_logs` VALUES (211, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 16:34:58');
INSERT INTO `operation_logs` VALUES (212, NULL, 1, '更新', '管理员1更新个人资料', NULL, NULL, '2025-04-14 16:35:59');
INSERT INTO `operation_logs` VALUES (213, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 16:35:59');
INSERT INTO `operation_logs` VALUES (214, NULL, 1, '更新', '管理员1更新个人资料', NULL, NULL, '2025-04-14 16:36:09');
INSERT INTO `operation_logs` VALUES (215, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 16:36:09');
INSERT INTO `operation_logs` VALUES (216, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 16:36:28');
INSERT INTO `operation_logs` VALUES (217, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 16:39:17');
INSERT INTO `operation_logs` VALUES (218, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 16:40:37');
INSERT INTO `operation_logs` VALUES (219, NULL, 1, '更新', '管理员1更新个人资料', NULL, NULL, '2025-04-14 16:41:06');
INSERT INTO `operation_logs` VALUES (220, NULL, 1, '更新', '管理员1更新个人资料（含手机号）', NULL, NULL, '2025-04-14 16:44:40');
INSERT INTO `operation_logs` VALUES (221, NULL, 1, '更新', '管理员1更新个人资料（含手机号）', NULL, NULL, '2025-04-14 16:44:47');
INSERT INTO `operation_logs` VALUES (222, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:34:04');
INSERT INTO `operation_logs` VALUES (223, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:01');
INSERT INTO `operation_logs` VALUES (224, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:06');
INSERT INTO `operation_logs` VALUES (225, 13, NULL, '下载文件', '用户13下载了文件[[主席令第14号]中华人民共和国农村土地承包经营纠纷调解仲裁法.docx]', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:24');
INSERT INTO `operation_logs` VALUES (226, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:36');
INSERT INTO `operation_logs` VALUES (227, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：4，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:38');
INSERT INTO `operation_logs` VALUES (228, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：3，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:39');
INSERT INTO `operation_logs` VALUES (229, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：2，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:39');
INSERT INTO `operation_logs` VALUES (230, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:40');
INSERT INTO `operation_logs` VALUES (231, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：3，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:43');
INSERT INTO `operation_logs` VALUES (232, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:44');
INSERT INTO `operation_logs` VALUES (233, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：赔偿', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:48');
INSERT INTO `operation_logs` VALUES (234, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：赔', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:49');
INSERT INTO `operation_logs` VALUES (235, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:49');
INSERT INTO `operation_logs` VALUES (236, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：赔偿', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:53');
INSERT INTO `operation_logs` VALUES (237, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：赔', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:53');
INSERT INTO `operation_logs` VALUES (238, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:36:53');
INSERT INTO `operation_logs` VALUES (239, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:38:49');
INSERT INTO `operation_logs` VALUES (240, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:39:46');
INSERT INTO `operation_logs` VALUES (241, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:40:36');
INSERT INTO `operation_logs` VALUES (242, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:41:45');
INSERT INTO `operation_logs` VALUES (243, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:42:47');
INSERT INTO `operation_logs` VALUES (244, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:46:42');
INSERT INTO `operation_logs` VALUES (245, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:46:48');
INSERT INTO `operation_logs` VALUES (246, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:46:53');
INSERT INTO `operation_logs` VALUES (247, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:46:55');
INSERT INTO `operation_logs` VALUES (248, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 17:46:57');
INSERT INTO `operation_logs` VALUES (249, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:15:34');
INSERT INTO `operation_logs` VALUES (250, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:20:57');
INSERT INTO `operation_logs` VALUES (251, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:21:01');
INSERT INTO `operation_logs` VALUES (252, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:24:01');
INSERT INTO `operation_logs` VALUES (253, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:24:38');
INSERT INTO `operation_logs` VALUES (254, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:24:38');
INSERT INTO `operation_logs` VALUES (255, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:25:27');
INSERT INTO `operation_logs` VALUES (256, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:27:44');
INSERT INTO `operation_logs` VALUES (257, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:27:44');
INSERT INTO `operation_logs` VALUES (258, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:27:49');
INSERT INTO `operation_logs` VALUES (259, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:27:49');
INSERT INTO `operation_logs` VALUES (260, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:28:55');
INSERT INTO `operation_logs` VALUES (261, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:28:55');
INSERT INTO `operation_logs` VALUES (262, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:29:33');
INSERT INTO `operation_logs` VALUES (263, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:29:37');
INSERT INTO `operation_logs` VALUES (264, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:29:37');
INSERT INTO `operation_logs` VALUES (265, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:32:32');
INSERT INTO `operation_logs` VALUES (266, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:32:32');
INSERT INTO `operation_logs` VALUES (267, 13, NULL, '查询', '用户13查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:38:30');
INSERT INTO `operation_logs` VALUES (268, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:38:30');
INSERT INTO `operation_logs` VALUES (269, 13, NULL, '查询', '用户13查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 18:40:42');

-- ----------------------------
-- Table structure for system_configs
-- ----------------------------
DROP TABLE IF EXISTS `system_configs`;
CREATE TABLE `system_configs`  (
  `config_id` int NOT NULL AUTO_INCREMENT,
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配置描述',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_configs
-- ----------------------------
INSERT INTO `system_configs` VALUES (1, 'knowledge_base_update_date', '2023-12-15', '知识库最后更新日期', '2025-04-11 13:58:34', '2025-04-11 13:58:34');
INSERT INTO `system_configs` VALUES (2, 'data_sources_count', '32', '知识库数据源数量', '2025-04-11 13:58:34', '2025-04-11 13:58:34');
INSERT INTO `system_configs` VALUES (3, 'response_time_limit', '2', '系统响应时间限制(秒)', '2025-04-11 13:58:34', '2025-04-11 13:58:34');
INSERT INTO `system_configs` VALUES (4, 'system_status', 'normal', '系统运行状态', '2025-04-11 13:58:34', '2025-04-14 11:25:11');

-- ----------------------------
-- Table structure for system_versions
-- ----------------------------
DROP TABLE IF EXISTS `system_versions`;
CREATE TABLE `system_versions`  (
  `version_id` int NOT NULL AUTO_INCREMENT,
  `version_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '版本号',
  `knowledge_base_version` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '知识库版本',
  `release_date` date NOT NULL COMMENT '发布日期',
  `update_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '更新说明',
  `is_current` tinyint NULL DEFAULT 0 COMMENT '是否当前版本: 0-否, 1-是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`version_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统版本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_versions
-- ----------------------------
INSERT INTO `system_versions` VALUES (1, '1.0.0', 'v3.2.1', '2025-04-11', '化工安全AI助手系统初始版本', 1, '2025-04-11 13:58:34');

-- ----------------------------
-- Table structure for user_feedback
-- ----------------------------
DROP TABLE IF EXISTS `user_feedback`;
CREATE TABLE `user_feedback`  (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID，允许匿名反馈',
  `feedback_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈类型',
  `feedback_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈内容',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `status` enum('pending','processing','resolved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '处理状态',
  `admin_reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '管理员回复',
  `replied_at` datetime NULL DEFAULT NULL COMMENT '回复时间',
  PRIMARY KEY (`feedback_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_feedback_type`(`feedback_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `user_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户反馈表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_feedback
-- ----------------------------
INSERT INTO `user_feedback` VALUES (1, 13, 'suggestion', '前端优化一下', '2025-04-14 12:36:12', 'pending', NULL, NULL);

-- ----------------------------
-- Table structure for user_tokens
-- ----------------------------
DROP TABLE IF EXISTS `user_tokens`;
CREATE TABLE `user_tokens`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录令牌',
  `device_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备信息',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `expire_at` datetime NOT NULL COMMENT '过期时间',
  `is_valid` tinyint NULL DEFAULT 1 COMMENT '是否有效: 0-无效, 1-有效',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token`(`token` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `user_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录令牌表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_tokens
-- ----------------------------
INSERT INTO `user_tokens` VALUES (4, 13, '806585bc-f9eb-4bb2-b4cf-9871d47a328e', NULL, NULL, '2025-04-14 18:52:15', '2025-04-21 18:52:16', 0);
INSERT INTO `user_tokens` VALUES (5, 13, 'e8990dd3-683a-4757-babc-188cd5b4a5c2', NULL, NULL, '2025-04-14 18:54:54', '2025-04-21 18:54:54', 1);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `mobile` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户手机号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '加密后的密码',
  `theme_preference` enum('light','dark') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'light' COMMENT '主题偏好',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `last_login_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后登录时间',
  `status` tinyint NULL DEFAULT 1 COMMENT '账号状态: 0-禁用, 1-正常',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `mobile`(`mobile` ASC) USING BTREE,
  INDEX `idx_mobile`(`mobile` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (13, '18350191687', 'c412e04cf954373dfea8db43c5984438', 'light', '2025-04-11 18:52:58', '2025-04-14 18:54:54', 1);

-- ----------------------------
-- Table structure for verification_codes
-- ----------------------------
DROP TABLE IF EXISTS `verification_codes`;
CREATE TABLE `verification_codes`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `mobile` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '验证码',
  `purpose` enum('login','register','reset_password') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用途',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `expire_at` datetime NOT NULL COMMENT '过期时间',
  `is_used` tinyint NULL DEFAULT 0 COMMENT '是否已使用: 0-未使用, 1-已使用',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_mobile_purpose`(`mobile` ASC, `purpose` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '验证码表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of verification_codes
-- ----------------------------
INSERT INTO `verification_codes` VALUES (13, '18350191687', '164152', 'register', '2025-04-11 18:46:24', '2025-04-11 19:01:24', 0);
INSERT INTO `verification_codes` VALUES (14, '18350191687', '875120', 'register', '2025-04-11 18:52:28', '2025-04-11 19:07:28', 1);
INSERT INTO `verification_codes` VALUES (15, '18350191687', '806379', 'login', '2025-04-11 21:42:14', '2025-04-11 21:57:14', 1);

SET FOREIGN_KEY_CHECKS = 1;
