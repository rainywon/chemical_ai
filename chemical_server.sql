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

 Date: 15/04/2025 14:34:35
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
INSERT INTO `admin_tokens` VALUES (1, 1, '8c10a855-2a3d-421d-abf7-c76316ce980e', NULL, NULL, '2025-04-15 11:11:58', '2025-04-16 11:11:58', 1);

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
INSERT INTO `admins` VALUES (1, '18350191687', 'c412e04cf954373dfea8db43c5984438', '吴凯歌', 'admin', '1028418330@qq.com', 1, '2025-04-15 11:11:58', '2025-04-12 14:52:07', '2025-04-15 11:11:58');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI模型配置表' ROW_FORMAT = DYNAMIC;

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
  `token` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`token` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_sessions
-- ----------------------------
INSERT INTO `chat_sessions` VALUES ('3ad1b243-41c0-4a2b-aee7-d9772300d832', 'f4076287-ceea-43e9-a310-6264e9b1593c', '粉尘治理怎么做', '2025-04-12 14:46:10', '2025-04-15 13:53:32');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '内容反馈表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of content_feedbacks
-- ----------------------------
INSERT INTO `content_feedbacks` VALUES (4, 13, 3, '不好啊', '回答不完整', '<think>\n我是DeepSeek-R1，一个由深度求索公司开发的智能助手，我擅长通过思考来帮您解答复杂的数学、代码和逻辑推理等问题。如果你有任何问题，随时可以告诉我！\n', '你能做什么\n', '2025-04-15 14:16:19', 'pending', NULL, NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '应急处理方案表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '反馈类型表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库分类表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库文档表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 342 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operation_logs
-- ----------------------------
INSERT INTO `operation_logs` VALUES (270, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:29:36');
INSERT INTO `operation_logs` VALUES (271, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:36:03');
INSERT INTO `operation_logs` VALUES (272, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:36:03');
INSERT INTO `operation_logs` VALUES (273, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:36:08');
INSERT INTO `operation_logs` VALUES (274, 13, NULL, '下载文件', '用户18350191687用户13(user)下载了文件[[主席令第16号]中华人民共和国行政诉讼法.docx]', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:36:09');
INSERT INTO `operation_logs` VALUES (275, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:36:53');
INSERT INTO `operation_logs` VALUES (276, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:36:53');
INSERT INTO `operation_logs` VALUES (277, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:38:35');
INSERT INTO `operation_logs` VALUES (278, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:39:46');
INSERT INTO `operation_logs` VALUES (279, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:39:46');
INSERT INTO `operation_logs` VALUES (280, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:39:56');
INSERT INTO `operation_logs` VALUES (281, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:39:59');
INSERT INTO `operation_logs` VALUES (282, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:39:59');
INSERT INTO `operation_logs` VALUES (283, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:40:00');
INSERT INTO `operation_logs` VALUES (284, 13, NULL, '下载文件', '用户18350191687下载了文件[[交办水函〔2022〕1107号]关于印发港口安全类重大风险专项防控措施的通知.pdf]', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:40:29');
INSERT INTO `operation_logs` VALUES (285, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:40:30');
INSERT INTO `operation_logs` VALUES (286, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:40:30');
INSERT INTO `operation_logs` VALUES (287, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:44:36');
INSERT INTO `operation_logs` VALUES (288, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:44:55');
INSERT INTO `operation_logs` VALUES (289, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:44:55');
INSERT INTO `operation_logs` VALUES (290, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:45:08');
INSERT INTO `operation_logs` VALUES (291, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:45:08');
INSERT INTO `operation_logs` VALUES (292, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:45:09');
INSERT INTO `operation_logs` VALUES (293, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:47:44');
INSERT INTO `operation_logs` VALUES (294, 13, NULL, '提交反馈', '用户18350191687提交了content类型的反馈', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:52:19');
INSERT INTO `operation_logs` VALUES (295, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:57:02');
INSERT INTO `operation_logs` VALUES (296, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 19:57:02');
INSERT INTO `operation_logs` VALUES (297, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 20:00:03');
INSERT INTO `operation_logs` VALUES (298, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 20:00:03');
INSERT INTO `operation_logs` VALUES (299, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 20:32:39');
INSERT INTO `operation_logs` VALUES (300, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 20:32:39');
INSERT INTO `operation_logs` VALUES (301, NULL, NULL, '登录', '管理员登录系统', NULL, NULL, '2025-04-14 20:32:57');
INSERT INTO `operation_logs` VALUES (302, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 20:32:58');
INSERT INTO `operation_logs` VALUES (303, NULL, 1, '查询', '管理员1查询个人资料', NULL, NULL, '2025-04-14 20:34:15');
INSERT INTO `operation_logs` VALUES (304, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:15:20');
INSERT INTO `operation_logs` VALUES (305, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:16:48');
INSERT INTO `operation_logs` VALUES (306, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:17:58');
INSERT INTO `operation_logs` VALUES (307, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:18:43');
INSERT INTO `operation_logs` VALUES (308, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:19:11');
INSERT INTO `operation_logs` VALUES (309, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:21:02');
INSERT INTO `operation_logs` VALUES (310, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:22:18');
INSERT INTO `operation_logs` VALUES (311, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:26:05');
INSERT INTO `operation_logs` VALUES (312, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:26:44');
INSERT INTO `operation_logs` VALUES (313, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:27:29');
INSERT INTO `operation_logs` VALUES (314, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:28:21');
INSERT INTO `operation_logs` VALUES (315, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:29:00');
INSERT INTO `operation_logs` VALUES (316, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:29:54');
INSERT INTO `operation_logs` VALUES (317, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:30:16');
INSERT INTO `operation_logs` VALUES (318, NULL, 1, '查询', '吴凯歌查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 21:30:17');
INSERT INTO `operation_logs` VALUES (319, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-14 21:30:17');
INSERT INTO `operation_logs` VALUES (320, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:31:48');
INSERT INTO `operation_logs` VALUES (321, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-14 21:32:30');
INSERT INTO `operation_logs` VALUES (322, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-14 21:32:31');
INSERT INTO `operation_logs` VALUES (323, NULL, 1, '更新', '吴凯歌更新了个人资料', NULL, NULL, '2025-04-14 21:32:50');
INSERT INTO `operation_logs` VALUES (324, NULL, 1, '更新', '吴凯更新了个人资料', NULL, NULL, '2025-04-14 21:33:27');
INSERT INTO `operation_logs` VALUES (325, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-14 21:54:58');
INSERT INTO `operation_logs` VALUES (326, NULL, 1, '查询', '吴凯歌查询应急预案文件列表', NULL, NULL, '2025-04-14 21:55:40');
INSERT INTO `operation_logs` VALUES (327, NULL, 1, '查询', '吴凯歌在线查看了PDF文件[AQ 1020—2021]煤矿井下粉尘综合防治技术规范.pdf', NULL, NULL, '2025-04-14 21:55:46');
INSERT INTO `operation_logs` VALUES (328, NULL, 1, '下载文件', '吴凯歌下载应急预案文件[AQ 1020—2021]煤矿井下粉尘综合防治技术规范.pdf', NULL, NULL, '2025-04-14 21:55:51');
INSERT INTO `operation_logs` VALUES (329, NULL, 1, '查询', '吴凯歌在线查看了PDF文件[AQ 1043—2007]矿用产品安全标志标识.pdf', NULL, NULL, '2025-04-14 21:56:15');
INSERT INTO `operation_logs` VALUES (330, NULL, 1, '查询', '吴凯歌查询知识库文件列表', NULL, NULL, '2025-04-14 22:02:29');
INSERT INTO `operation_logs` VALUES (331, NULL, 1, '下载文件', '吴凯歌下载了文件[AQ 016—008]含硫化氢天然气井失控井口点火时间规定.xlsx', NULL, NULL, '2025-04-14 22:02:31');
INSERT INTO `operation_logs` VALUES (332, NULL, 1, '查询', '吴凯歌预览了文件[AQ 016—008]含硫化氢天然气井失控井口点火时间规定.xlsx', NULL, NULL, '2025-04-14 22:02:42');
INSERT INTO `operation_logs` VALUES (333, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表', NULL, NULL, '2025-04-14 22:07:37');
INSERT INTO `operation_logs` VALUES (334, NULL, 1, '查询', '吴凯歌预览了安全资料文件[AQ 2021—2008]金属非金属矿山在用摩擦式提升机安全检测检验规范.pdf', NULL, NULL, '2025-04-14 22:07:39');
INSERT INTO `operation_logs` VALUES (335, NULL, 1, '下载文件', '吴凯歌下载了安全资料文件[AQ 2021—2008]金属非金属矿山在用摩擦式提升机安全检测检验规范.pdf', NULL, NULL, '2025-04-14 22:07:45');
INSERT INTO `operation_logs` VALUES (336, NULL, 1, '查询', '吴凯歌查询AI内容反馈列表', NULL, NULL, '2025-04-14 22:12:30');
INSERT INTO `operation_logs` VALUES (337, NULL, 1, '查询', '吴凯歌查询AI内容反馈统计', NULL, NULL, '2025-04-14 22:12:31');
INSERT INTO `operation_logs` VALUES (338, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 11:11:48');
INSERT INTO `operation_logs` VALUES (339, NULL, 1, '查询', '吴凯歌查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 11:11:48');
INSERT INTO `operation_logs` VALUES (340, NULL, 1, '登录', '管理员[吴凯歌]登录系统', NULL, NULL, '2025-04-15 11:11:58');
INSERT INTO `operation_logs` VALUES (341, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:11:59');
INSERT INTO `operation_logs` VALUES (342, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:31:05');
INSERT INTO `operation_logs` VALUES (343, NULL, 1, '查询', '吴凯歌查询系统配置参数', NULL, NULL, '2025-04-15 11:31:10');
INSERT INTO `operation_logs` VALUES (344, NULL, 1, '查询', '吴凯歌查询系统版本列表', NULL, NULL, '2025-04-15 11:31:10');
INSERT INTO `operation_logs` VALUES (345, NULL, 1, '查询', '吴凯歌查询系统配置参数', NULL, NULL, '2025-04-15 11:31:12');
INSERT INTO `operation_logs` VALUES (346, NULL, 1, '查询', '吴凯歌查询系统配置参数', NULL, NULL, '2025-04-15 11:31:14');
INSERT INTO `operation_logs` VALUES (347, NULL, 1, '更新', '吴凯歌更新系统配置1', NULL, NULL, '2025-04-15 11:31:34');
INSERT INTO `operation_logs` VALUES (348, NULL, 1, '查询', '吴凯歌查询系统配置参数', NULL, NULL, '2025-04-15 11:31:34');
INSERT INTO `operation_logs` VALUES (349, NULL, 1, '更新', '吴凯歌更新系统配置2', NULL, NULL, '2025-04-15 11:31:58');
INSERT INTO `operation_logs` VALUES (350, NULL, 1, '查询', '吴凯歌查询系统配置参数', NULL, NULL, '2025-04-15 11:31:58');
INSERT INTO `operation_logs` VALUES (351, NULL, 1, '查询', '吴凯歌查询系统版本列表', NULL, NULL, '2025-04-15 11:32:04');
INSERT INTO `operation_logs` VALUES (352, NULL, 1, '查询', '吴凯歌查询AI内容反馈列表', NULL, NULL, '2025-04-15 11:41:27');
INSERT INTO `operation_logs` VALUES (353, NULL, 1, '查询', '吴凯歌查询AI内容反馈统计', NULL, NULL, '2025-04-15 11:41:27');
INSERT INTO `operation_logs` VALUES (354, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:41:28');
INSERT INTO `operation_logs` VALUES (355, NULL, 1, '查询', '吴凯歌查询系统功能反馈统计', NULL, NULL, '2025-04-15 11:41:28');
INSERT INTO `operation_logs` VALUES (356, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:41:32');
INSERT INTO `operation_logs` VALUES (357, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:41:34');
INSERT INTO `operation_logs` VALUES (358, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:41:34');
INSERT INTO `operation_logs` VALUES (359, NULL, 1, '更新', '吴凯歌更新系统功能反馈2状态为processing', NULL, NULL, '2025-04-15 11:41:44');
INSERT INTO `operation_logs` VALUES (360, NULL, 1, '查询', '吴凯歌查询系统功能反馈统计', NULL, NULL, '2025-04-15 11:41:44');
INSERT INTO `operation_logs` VALUES (361, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:42:05');
INSERT INTO `operation_logs` VALUES (362, NULL, 1, '更新', '吴凯歌更新系统功能反馈2状态为resolved', NULL, NULL, '2025-04-15 11:42:11');
INSERT INTO `operation_logs` VALUES (363, NULL, 1, '查询', '吴凯歌查询系统功能反馈统计', NULL, NULL, '2025-04-15 11:42:11');
INSERT INTO `operation_logs` VALUES (364, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:42:13');
INSERT INTO `operation_logs` VALUES (365, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 11:42:14');
INSERT INTO `operation_logs` VALUES (366, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:53:07');
INSERT INTO `operation_logs` VALUES (367, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:53:20');
INSERT INTO `operation_logs` VALUES (368, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:54:56');
INSERT INTO `operation_logs` VALUES (369, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:55:00');
INSERT INTO `operation_logs` VALUES (370, NULL, 1, '更新', '吴凯歌禁用用户13', NULL, NULL, '2025-04-15 11:55:14');
INSERT INTO `operation_logs` VALUES (371, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:55:14');
INSERT INTO `operation_logs` VALUES (372, NULL, 1, '更新', '吴凯歌启用用户13', NULL, NULL, '2025-04-15 11:55:26');
INSERT INTO `operation_logs` VALUES (373, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:55:26');
INSERT INTO `operation_logs` VALUES (374, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:55:33');
INSERT INTO `operation_logs` VALUES (375, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:55:35');
INSERT INTO `operation_logs` VALUES (376, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 11:56:25');
INSERT INTO `operation_logs` VALUES (377, NULL, 1, '查询', '吴凯歌查询用户登录历史', NULL, NULL, '2025-04-15 11:58:31');
INSERT INTO `operation_logs` VALUES (378, NULL, 1, '查询', '吴凯歌查看用户13详情', NULL, NULL, '2025-04-15 11:58:34');
INSERT INTO `operation_logs` VALUES (379, NULL, 1, '查询', '吴凯歌查询用户登录历史', NULL, NULL, '2025-04-15 11:59:05');
INSERT INTO `operation_logs` VALUES (380, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:59:05');
INSERT INTO `operation_logs` VALUES (381, NULL, 1, '查询', '吴凯歌查询用户登录历史', NULL, NULL, '2025-04-15 11:59:21');
INSERT INTO `operation_logs` VALUES (382, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:59:21');
INSERT INTO `operation_logs` VALUES (383, NULL, 1, '查询', '吴凯歌查询用户登录历史', NULL, NULL, '2025-04-15 11:59:51');
INSERT INTO `operation_logs` VALUES (384, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 11:59:51');
INSERT INTO `operation_logs` VALUES (385, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:03:56');
INSERT INTO `operation_logs` VALUES (386, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:05');
INSERT INTO `operation_logs` VALUES (387, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:04:05');
INSERT INTO `operation_logs` VALUES (388, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:34');
INSERT INTO `operation_logs` VALUES (389, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:36');
INSERT INTO `operation_logs` VALUES (390, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:39');
INSERT INTO `operation_logs` VALUES (391, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:45');
INSERT INTO `operation_logs` VALUES (392, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:50');
INSERT INTO `operation_logs` VALUES (393, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:52');
INSERT INTO `operation_logs` VALUES (394, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:55');
INSERT INTO `operation_logs` VALUES (395, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:04:57');
INSERT INTO `operation_logs` VALUES (396, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:05:31');
INSERT INTO `operation_logs` VALUES (397, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:06:59');
INSERT INTO `operation_logs` VALUES (398, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:07:51');
INSERT INTO `operation_logs` VALUES (399, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:08:14');
INSERT INTO `operation_logs` VALUES (400, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:08:39');
INSERT INTO `operation_logs` VALUES (401, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:11:17');
INSERT INTO `operation_logs` VALUES (402, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:16:25');
INSERT INTO `operation_logs` VALUES (403, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:20:56');
INSERT INTO `operation_logs` VALUES (404, NULL, 1, '查询', '吴凯歌查询知识库文件列表', NULL, NULL, '2025-04-15 12:21:07');
INSERT INTO `operation_logs` VALUES (405, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表', NULL, NULL, '2025-04-15 12:21:09');
INSERT INTO `operation_logs` VALUES (406, NULL, 1, '查询', '管理员1查询操作日志', NULL, NULL, '2025-04-15 12:21:11');
INSERT INTO `operation_logs` VALUES (407, NULL, 1, '查询', '吴凯歌查询用户列表', NULL, NULL, '2025-04-15 12:21:12');
INSERT INTO `operation_logs` VALUES (408, NULL, 1, '查询', '吴凯歌查询用户登录历史', NULL, NULL, '2025-04-15 12:21:13');
INSERT INTO `operation_logs` VALUES (409, NULL, 1, '查询', '吴凯歌查询知识库文件列表', NULL, NULL, '2025-04-15 12:21:18');
INSERT INTO `operation_logs` VALUES (410, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表', NULL, NULL, '2025-04-15 12:21:19');
INSERT INTO `operation_logs` VALUES (411, NULL, 1, '查询', '吴凯歌查询应急预案文件列表', NULL, NULL, '2025-04-15 12:21:20');
INSERT INTO `operation_logs` VALUES (412, NULL, 1, '查询', '吴凯歌查询系统功能反馈列表', NULL, NULL, '2025-04-15 12:21:21');
INSERT INTO `operation_logs` VALUES (413, NULL, 1, '查询', '吴凯歌查询系统功能反馈统计', NULL, NULL, '2025-04-15 12:21:21');
INSERT INTO `operation_logs` VALUES (414, NULL, 1, '查询', '吴凯歌查询AI内容反馈统计', NULL, NULL, '2025-04-15 12:21:23');
INSERT INTO `operation_logs` VALUES (415, NULL, 1, '查询', '吴凯歌查询AI内容反馈列表', NULL, NULL, '2025-04-15 12:21:23');
INSERT INTO `operation_logs` VALUES (416, NULL, 1, '查询', '吴凯歌查询系统配置参数', NULL, NULL, '2025-04-15 12:21:25');
INSERT INTO `operation_logs` VALUES (417, NULL, 1, '查询', '吴凯歌查询系统版本列表', NULL, NULL, '2025-04-15 12:21:25');
INSERT INTO `operation_logs` VALUES (418, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表', NULL, NULL, '2025-04-15 12:21:53');
INSERT INTO `operation_logs` VALUES (419, NULL, 1, '查询', '吴凯歌查询知识库文件列表', NULL, NULL, '2025-04-15 12:21:54');
INSERT INTO `operation_logs` VALUES (420, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:23:11');
INSERT INTO `operation_logs` VALUES (421, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:23:28');
INSERT INTO `operation_logs` VALUES (422, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:25:52');
INSERT INTO `operation_logs` VALUES (423, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:32:28');
INSERT INTO `operation_logs` VALUES (424, NULL, 1, '查询', '管理员吴凯歌查询个人资料', NULL, NULL, '2025-04-15 12:34:45');
INSERT INTO `operation_logs` VALUES (425, NULL, 1, '查询', '吴凯歌查询用户登录历史', NULL, NULL, '2025-04-15 12:35:02');
INSERT INTO `operation_logs` VALUES (426, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 12:41:54');
INSERT INTO `operation_logs` VALUES (427, NULL, 1, '查询', '吴凯歌查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 12:41:54');
INSERT INTO `operation_logs` VALUES (428, NULL, 1, '查询', '吴凯歌查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 12:41:55');
INSERT INTO `operation_logs` VALUES (429, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 12:41:57');
INSERT INTO `operation_logs` VALUES (430, NULL, 1, '查询', '吴凯歌查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 12:41:57');
INSERT INTO `operation_logs` VALUES (431, NULL, 1, '查询', '吴凯歌查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:05:29');
INSERT INTO `operation_logs` VALUES (432, NULL, 1, '查询', '吴凯歌查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:05:29');
INSERT INTO `operation_logs` VALUES (433, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:11:45');
INSERT INTO `operation_logs` VALUES (434, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:12:22');
INSERT INTO `operation_logs` VALUES (435, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:17:49');
INSERT INTO `operation_logs` VALUES (436, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:17:49');
INSERT INTO `operation_logs` VALUES (437, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:18:07');
INSERT INTO `operation_logs` VALUES (438, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:18:08');
INSERT INTO `operation_logs` VALUES (439, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:18:08');
INSERT INTO `operation_logs` VALUES (440, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:23:05');
INSERT INTO `operation_logs` VALUES (441, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:23:06');
INSERT INTO `operation_logs` VALUES (442, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:23:15');
INSERT INTO `operation_logs` VALUES (443, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:23:15');
INSERT INTO `operation_logs` VALUES (444, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:32:59');
INSERT INTO `operation_logs` VALUES (445, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:32:59');
INSERT INTO `operation_logs` VALUES (446, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:52:25');
INSERT INTO `operation_logs` VALUES (447, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:52:25');
INSERT INTO `operation_logs` VALUES (448, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:53:45');
INSERT INTO `operation_logs` VALUES (449, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:53:45');
INSERT INTO `operation_logs` VALUES (450, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:53:55');
INSERT INTO `operation_logs` VALUES (451, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 13:53:55');
INSERT INTO `operation_logs` VALUES (452, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 14:12:17');
INSERT INTO `operation_logs` VALUES (453, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 14:12:17');
INSERT INTO `operation_logs` VALUES (454, 13, NULL, '查询', '用户18350191687查询安全资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 14:12:32');
INSERT INTO `operation_logs` VALUES (455, 13, NULL, '查询', '用户18350191687查询应急资料库文件列表，页码：1，搜索关键词：无', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '2025-04-15 14:12:32');
INSERT INTO `operation_logs` VALUES (456, 13, NULL, '提交反馈', '用户13提交了回答不完整类型的反馈', NULL, NULL, '2025-04-15 14:16:19');

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
INSERT INTO `system_configs` VALUES (1, 'knowledge_base_update_date', '2023-11-16', '知识库最后更新日期', '2025-04-11 13:58:34', '2025-04-15 11:31:34');
INSERT INTO `system_configs` VALUES (2, 'data_sources_count', '1', '知识库数据源数量', '2025-04-11 13:58:34', '2025-04-15 11:31:58');
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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户反馈表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_feedback
-- ----------------------------
INSERT INTO `user_feedback` VALUES (1, 13, 'suggestion', '前端优化一下', '2025-04-14 12:36:12', 'pending', NULL, NULL);
INSERT INTO `user_feedback` VALUES (2, 13, 'content', '改进一下内容', '2025-04-14 19:52:19', 'resolved', '好的', '2025-04-15 11:42:11');

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录令牌表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_tokens
-- ----------------------------
INSERT INTO `user_tokens` VALUES (8, 13, 'f4076287-ceea-43e9-a310-6264e9b1593c', NULL, NULL, '2025-04-15 13:52:24', '2025-04-22 13:52:24', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (13, '18350191687', 'c412e04cf954373dfea8db43c5984438', 'light', '2025-04-11 18:52:58', '2025-04-15 14:12:16', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '验证码表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of verification_codes
-- ----------------------------
INSERT INTO `verification_codes` VALUES (13, '18350191687', '164152', 'register', '2025-04-11 18:46:24', '2025-04-11 19:01:24', 0);
INSERT INTO `verification_codes` VALUES (14, '18350191687', '875120', 'register', '2025-04-11 18:52:28', '2025-04-11 19:07:28', 1);
INSERT INTO `verification_codes` VALUES (15, '18350191687', '806379', 'login', '2025-04-11 21:42:14', '2025-04-11 21:57:14', 1);

SET FOREIGN_KEY_CHECKS = 1;
