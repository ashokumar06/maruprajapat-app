import re

file_path = 'backend/app/api/v1/events.py'
with open(file_path, 'r') as f:
    content = f.read()

# Update the sorting logic
sorting_old = """    if upcoming is not None:
        if upcoming:
            count_query = count_query.where(Event.start_date >= datetime.utcnow())
            query = query.where(Event.start_date >= datetime.utcnow())
        else:
            count_query = count_query.where(Event.start_date < datetime.utcnow())
            query = query.where(Event.start_date < datetime.utcnow())
        
    if community_id is not None:
        count_query = count_query.where(Event.community_id == community_id)
        query = query.where(Event.community_id == community_id)

    total_result = await db.execute(count_query)
    total = total_result.scalar_one()

    query = query.order_by(Event.start_date.asc()).offset(offset).limit(per_page)"""

sorting_new = """    if upcoming is not None:
        if upcoming:
            count_query = count_query.where(Event.start_date >= datetime.utcnow())
            query = query.where(Event.start_date >= datetime.utcnow())
            query = query.order_by(Event.start_date.asc())
        else:
            count_query = count_query.where(Event.start_date < datetime.utcnow())
            query = query.where(Event.start_date < datetime.utcnow())
            query = query.order_by(Event.start_date.desc())
    else:
        query = query.order_by(Event.start_date.desc())
        
    if community_id is not None:
        count_query = count_query.where(Event.community_id == community_id)
        query = query.where(Event.community_id == community_id)

    total_result = await db.execute(count_query)
    total = total_result.scalar_one()

    query = query.offset(offset).limit(per_page)"""

content = content.replace(sorting_old, sorting_new)

with open(file_path, 'w') as f:
    f.write(content)
