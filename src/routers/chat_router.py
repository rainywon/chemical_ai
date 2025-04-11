from fastapi import APIRouter, HTTPException, Depends, Query
from typing import List, Optional
from datetime import datetime
import uuid
from pydantic import BaseModel
from database import get_db
from sqlalchemy.orm import Session
from sqlalchemy import desc
import json

router = APIRouter()

class ChatSessionBase(BaseModel):
    user_id: str
    title: str

class ChatSessionCreate(ChatSessionBase):
    pass

class ChatSession(ChatSessionBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ChatMessageBase(BaseModel):
    session_id: str
    message_type: str
    content: str
    parent_id: Optional[str] = None
    paired_ai_id: Optional[str] = None
    references: Optional[dict] = None
    question: Optional[str] = None
    is_loading: bool = False

class ChatMessageCreate(ChatMessageBase):
    pass

class ChatMessage(ChatMessageBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

def get_chat_sessions_db(user_id: str, db: Session):
    """从数据库获取用户的所有聊天会话"""
    try:
        query = """
            SELECT id, user_id, title, created_at, updated_at 
            FROM chat_sessions 
            WHERE user_id = :user_id 
            ORDER BY updated_at DESC
        """
        result = db.execute(query, {"user_id": user_id})
        return [dict(row) for row in result]
    except Exception as e:
        print(f"获取会话列表失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取会话列表失败")

def create_chat_session_db(session_data: dict, db: Session):
    """创建新的聊天会话"""
    try:
        session_id = str(uuid.uuid4())
        query = """
            INSERT INTO chat_sessions 
            (id, user_id, title, created_at, updated_at) 
            VALUES 
            (:id, :user_id, :title, :created_at, :updated_at)
        """
        params = {
            "id": session_id,
            "user_id": session_data["user_id"],
            "title": session_data["title"],
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }
        db.execute(query, params)
        db.commit()
        return {"id": session_id, **session_data}
    except Exception as e:
        print(f"创建会话失败: {str(e)}")
        raise HTTPException(status_code=500, detail="创建会话失败")

def delete_chat_session_db(session_id: str, db: Session):
    """删除聊天会话及其所有消息"""
    try:
        # 删除会话相关的所有消息
        query = "DELETE FROM chat_messages WHERE session_id = :session_id"
        db.execute(query, {"session_id": session_id})
        
        # 删除会话
        query = "DELETE FROM chat_sessions WHERE id = :session_id"
        result = db.execute(query, {"session_id": session_id})
        db.commit()
        
        if result.rowcount == 0:
            raise HTTPException(status_code=404, detail="会话不存在")
            
        return {"message": "会话已删除"}
    except HTTPException:
        raise
    except Exception as e:
        print(f"删除会话失败: {str(e)}")
        raise HTTPException(status_code=500, detail="删除会话失败")

def clear_user_sessions_db(user_id: str, db: Session):
    """清空用户的所有聊天会话"""
    try:
        # 删除用户的所有消息
        query = """
            DELETE FROM chat_messages 
            WHERE session_id IN (
                SELECT id FROM chat_sessions WHERE user_id = :user_id
            )
        """
        db.execute(query, {"user_id": user_id})
        
        # 删除用户的所有会话
        query = "DELETE FROM chat_sessions WHERE user_id = :user_id"
        db.execute(query, {"user_id": user_id})
        
        db.commit()
        return {"message": "所有会话已清空"}
    except Exception as e:
        print(f"清空会话失败: {str(e)}")
        raise HTTPException(status_code=500, detail="清空会话失败")

def get_chat_messages_db(session_id: str, db: Session):
    """获取特定会话的所有消息"""
    try:
        query = """
            SELECT id, session_id, message_type, content, parent_id, 
                   paired_ai_id, references, question, is_loading, created_at
            FROM chat_messages 
            WHERE session_id = :session_id 
            ORDER BY created_at
        """
        result = db.execute(query, {"session_id": session_id})
        return [dict(row) for row in result]
    except Exception as e:
        print(f"获取消息失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取消息失败")

def create_chat_message_db(message_data: dict, db: Session):
    """创建新的聊天消息"""
    try:
        # 检查会话是否存在
        query = "SELECT id FROM chat_sessions WHERE id = :session_id"
        result = db.execute(query, {"session_id": message_data["session_id"]}).first()
        if not result:
            raise HTTPException(status_code=404, detail="会话不存在")
        
        # 更新会话的更新时间
        query = """
            UPDATE chat_sessions 
            SET updated_at = :updated_at 
            WHERE id = :session_id
        """
        db.execute(query, {
            "updated_at": datetime.now(),
            "session_id": message_data["session_id"]
        })
        
        # 创建新消息
        message_id = str(uuid.uuid4())
        query = """
            INSERT INTO chat_messages 
            (id, session_id, message_type, content, parent_id, paired_ai_id, 
             references, question, is_loading, created_at) 
            VALUES 
            (:id, :session_id, :message_type, :content, :parent_id, :paired_ai_id, 
             :references, :question, :is_loading, :created_at)
        """
        params = {
            "id": message_id,
            "session_id": message_data["session_id"],
            "message_type": message_data["message_type"],
            "content": message_data["content"],
            "parent_id": message_data.get("parent_id"),
            "paired_ai_id": message_data.get("paired_ai_id"),
            "references": json.dumps(message_data.get("references")) if message_data.get("references") else None,
            "question": message_data.get("question"),
            "is_loading": message_data.get("is_loading", False),
            "created_at": datetime.now()
        }
        db.execute(query, params)
        db.commit()
        
        return {"id": message_id, **message_data}
    except HTTPException:
        raise
    except Exception as e:
        print(f"创建消息失败: {str(e)}")
        raise HTTPException(status_code=500, detail="创建消息失败")

@router.get("/sessions", response_model=List[ChatSession])
async def get_chat_sessions(
    user_id: str = Query(..., description="用户ID"),
    db: Session = Depends(get_db)
):
    """获取用户的所有聊天会话"""
    return get_chat_sessions_db(user_id, db)

@router.post("/sessions", response_model=ChatSession)
async def create_chat_session(
    session: ChatSessionCreate,
    db: Session = Depends(get_db)
):
    """创建新的聊天会话"""
    return create_chat_session_db(session.dict(), db)

@router.delete("/sessions/{session_id}")
async def delete_chat_session(
    session_id: str,
    db: Session = Depends(get_db)
):
    """删除聊天会话及其所有消息"""
    return delete_chat_session_db(session_id, db)

@router.delete("/sessions/clear")
async def clear_user_sessions(
    user_id: str = Query(..., description="用户ID"),
    db: Session = Depends(get_db)
):
    """清空用户的所有聊天会话"""
    return clear_user_sessions_db(user_id, db)

@router.get("/messages", response_model=List[ChatMessage])
async def get_chat_messages(
    session_id: str = Query(..., description="会话ID"),
    db: Session = Depends(get_db)
):
    """获取特定会话的所有消息"""
    return get_chat_messages_db(session_id, db)

@router.post("/messages", response_model=ChatMessage)
async def create_chat_message(
    message: ChatMessageCreate,
    db: Session = Depends(get_db)
):
    """创建新的聊天消息"""
    return create_chat_message_db(message.dict(), db) 