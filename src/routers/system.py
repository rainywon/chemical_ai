from fastapi import APIRouter, HTTPException
from typing import Dict, Any
from datetime import datetime
from database import execute_query

router = APIRouter()

@router.get("/system/status")
async def get_system_status() -> Dict[str, Any]:
    """
    获取系统状态信息
    """
    try:
        # 获取当前版本信息
        version_info = execute_query("""
            SELECT version_number, knowledge_base_version, release_date 
            FROM system_versions 
            WHERE is_current = 1
        """)
        
        if not version_info:
            raise HTTPException(status_code=404, detail="未找到当前版本信息")
            
        version_info = version_info[0]  # 获取第一条记录
        
        # 获取系统配置信息
        configs = execute_query("""
            SELECT config_key, config_value 
            FROM system_configs 
            WHERE config_key IN ('data_source_count', 'response_time')
        """)
        
        # 转换为字典格式
        config_dict = {item['config_key']: item['config_value'] for item in configs}
        
        return {
            "knowledge_base": version_info['knowledge_base_version'],
            "update_date": version_info['release_date'].strftime("%Y-%m-%d"),
            "data_sources": f"{config_dict.get('data_source_count', '0')}个专业库",
            "response_time": f"≤ {config_dict.get('response_time', '2')}秒"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"系统错误: {str(e)}") 