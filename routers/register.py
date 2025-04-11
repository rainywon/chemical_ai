# 引入 FastAPI 中的 APIRouter 和 HTTPException 模块，用于创建路由和处理异常
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer
# 引入 Pydantic 中的 BaseModel 类，用于定义请求体的数据结构和验证
from pydantic import BaseModel, validator
# 从数据库模块导入 execute_query 和 execute_update 函数，用于执行查询和更新操作
from database import execute_query, execute_update
# 导入密码哈希处理模块
import hashlib
# 导入用于生成Token的模块
import uuid
import datetime

# 初始化 APIRouter 实例，用于定义路由
router = APIRouter()


# 定义请求体的模型，使用 Pydantic 的 BaseModel 来验证请求的数据
class RegisterRequest(BaseModel):
    # 定义注册请求所需的字段
    mobile: str
    code: str  # 验证码
    password: str
    confirm_password: str
    nickname: str = None  # 可选字段，用户昵称

    # 验证器方法，确保两次输入的密码一致
    @validator('confirm_password')
    def passwords_match(cls, v, values, **kwargs):
        if 'password' in values and v != values['password']:
            raise ValueError('两次输入的密码不一致')
        return v


# 创建一个 POST 请求的路由，路径为 "/register/"
@router.post("/register/")
# 异步处理函数，接收 RegisterRequest 类型的请求体
async def register(request: RegisterRequest):
    try:
        # 验证请求参数
        if not request.mobile or len(request.mobile) != 11:
            return {"code": 400, "message": "请提供有效的11位手机号码"}
        
        if not request.code:
            return {"code": 400, "message": "验证码不能为空"}
        
        if not request.password or len(request.password) < 6:
            return {"code": 400, "message": "密码长度不能小于6位"}

        # 检查手机号是否已注册
        user_exists = execute_query("SELECT user_id FROM users WHERE mobile = %s LIMIT 1", (request.mobile,))
        if user_exists:
            return {"code": 400, "message": "该手机号已注册，请直接登录"}

        # 验证验证码
        code_result = execute_query(
            """SELECT * FROM verification_codes 
               WHERE mobile = %s AND code = %s AND purpose = 'register' AND is_used = 0 
               AND expire_at > NOW() ORDER BY created_at DESC LIMIT 1""",
            (request.mobile, request.code)
        )

        if not code_result:
            return {"code": 400, "message": "验证码错误或已过期"}

        # 获取验证码记录ID
        code_id = code_result[0]['id']

        # 使用MD5哈希处理密码
        hashed_password = hashlib.md5(request.password.encode()).hexdigest()

        # 设置用户昵称，如果没有提供，则使用默认值
        nickname = request.nickname if request.nickname else f"用户{request.mobile[-4:]}"

        # 注册用户，插入用户表
        user_id = execute_update(
            """INSERT INTO users (mobile, password, nickname, theme_preference, register_time, status) 
               VALUES (%s, %s, %s, 'light', NOW(), 1)""",
            (request.mobile, hashed_password, nickname)
        )

        # 标记验证码为已使用
        execute_update("UPDATE verification_codes SET is_used = 1 WHERE id = %s", (code_id,))

        # 生成登录令牌
        token = str(uuid.uuid4())
        # 设置令牌过期时间（7天后）
        expire_at = datetime.datetime.now() + datetime.timedelta(days=7)
        
        # 记录用户登录令牌
        execute_update(
            """INSERT INTO user_tokens (user_id, token, created_at, expire_at, is_valid) 
               VALUES (%s, %s, NOW(), %s, 1)""",
            (user_id, token, expire_at)
        )

        # 返回成功注册的响应
        return {
            "code": 200, 
            "message": "注册成功", 
            "user_id": user_id,
            "token": token
        }

    # 捕获异常并返回 HTTP 500 错误，附带错误信息
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 