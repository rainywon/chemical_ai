from fastapi import APIRouter, HTTPException, Depends, Body
from pydantic import BaseModel, Field
from typing import List, Optional
from database import execute_query, execute_update, execute_transaction
from routers.login import get_current_user
import uuid
from datetime import datetime

# 初始化 APIRouter 实例，用于定义路由
router = APIRouter()

# 定义消息模型
class Message(BaseModel):
    message_id: Optional[int] = None
    sender_type: str
    message_text: str
    message_type: str = "text"
    created_at: Optional[datetime] = None

# 定义聊天会话模型
class Conversation(BaseModel):
    conversation_id: str
    title: Optional[str] = None
    messages: List[Message] = []
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# 创建新的聊天会话
@router.post("/conversations/")
async def create_conversation(title: str = Body(None), user_id: int = Depends(get_current_user)):
    try:
        # 生成会话ID
        conversation_id = str(uuid.uuid4())
        
        # 默认标题
        if not title:
            title = f"新对话 {datetime.now().strftime('%Y-%m-%d %H:%M')}"
            
        # 创建会话
        execute_update(
            """INSERT INTO chat_conversations (conversation_id, user_id, title, created_at, updated_at) 
               VALUES (%s, %s, %s, NOW(), NOW())""",
            (conversation_id, user_id, title)
        )
        
        return {
            "code": 200,
            "message": "会话创建成功",
            "data": {
                "conversation_id": conversation_id,
                "title": title
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 获取用户的所有聊天会话
@router.get("/conversations/")
async def get_conversations(user_id: int = Depends(get_current_user)):
    try:
        conversations = execute_query(
            """SELECT conversation_id, title, created_at, updated_at 
               FROM chat_conversations 
               WHERE user_id = %s 
               ORDER BY updated_at DESC""",
            (user_id,)
        )
        
        return {
            "code": 200,
            "message": "获取会话列表成功",
            "data": conversations
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 获取特定会话的所有消息
@router.get("/conversations/{conversation_id}/messages/")
async def get_messages(conversation_id: str, user_id: int = Depends(get_current_user)):
    try:
        # 验证会话所有权
        conversation = execute_query(
            """SELECT * FROM chat_conversations 
               WHERE conversation_id = %s AND user_id = %s""",
            (conversation_id, user_id)
        )
        
        if not conversation:
            return {"code": 404, "message": "会话不存在或无权访问"}
        
        # 获取会话中的所有消息
        messages = execute_query(
            """SELECT message_id, sender_type, message_text, message_type, created_at 
               FROM chat_messages 
               WHERE conversation_id = %s 
               ORDER BY created_at ASC""",
            (conversation_id,)
        )
        
        return {
            "code": 200,
            "message": "获取消息成功",
            "data": {
                "conversation": conversation[0],
                "messages": messages
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 添加消息到会话
@router.post("/conversations/{conversation_id}/messages/")
async def add_message(
    conversation_id: str, 
    message: Message,
    user_id: int = Depends(get_current_user)
):
    try:
        # 验证会话所有权
        conversation = execute_query(
            """SELECT * FROM chat_conversations 
               WHERE conversation_id = %s AND user_id = %s""",
            (conversation_id, user_id)
        )
        
        if not conversation:
            return {"code": 404, "message": "会话不存在或无权访问"}
        
        # 验证发送者类型
        if message.sender_type not in ["user", "ai"]:
            return {"code": 400, "message": "发送者类型无效，必须是 'user' 或 'ai'"}
        
        # 添加消息
        message_id = execute_update(
            """INSERT INTO chat_messages 
               (conversation_id, sender_type, message_text, message_type, created_at) 
               VALUES (%s, %s, %s, %s, NOW())""",
            (conversation_id, message.sender_type, message.message_text, message.message_type)
        )
        
        # 更新会话的更新时间
        execute_update(
            """UPDATE chat_conversations SET updated_at = NOW() WHERE conversation_id = %s""",
            (conversation_id,)
        )
        
        return {
            "code": 200,
            "message": "消息添加成功",
            "data": {
                "message_id": message_id
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 删除会话
@router.delete("/conversations/{conversation_id}/")
async def delete_conversation(conversation_id: str, user_id: int = Depends(get_current_user)):
    try:
        # 验证会话所有权
        conversation = execute_query(
            """SELECT * FROM chat_conversations 
               WHERE conversation_id = %s AND user_id = %s""",
            (conversation_id, user_id)
        )
        
        if not conversation:
            return {"code": 404, "message": "会话不存在或无权访问"}
        
        # 使用事务删除会话及其消息
        queries = [
            ("""DELETE FROM chat_messages WHERE conversation_id = %s""", (conversation_id,)),
            ("""DELETE FROM chat_conversations WHERE conversation_id = %s""", (conversation_id,))
        ]
        
        execute_transaction(queries)
        
        return {
            "code": 200,
            "message": "会话删除成功"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 修改会话标题
@router.put("/conversations/{conversation_id}/")
async def update_conversation(
    conversation_id: str, 
    title: str = Body(..., embed=True),
    user_id: int = Depends(get_current_user)
):
    try:
        # 验证会话所有权
        conversation = execute_query(
            """SELECT * FROM chat_conversations 
               WHERE conversation_id = %s AND user_id = %s""",
            (conversation_id, user_id)
        )
        
        if not conversation:
            return {"code": 404, "message": "会话不存在或无权访问"}
        
        # 更新标题
        execute_update(
            """UPDATE chat_conversations SET title = %s WHERE conversation_id = %s""",
            (title, conversation_id)
        )
        
        return {
            "code": 200,
            "message": "会话标题更新成功"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
