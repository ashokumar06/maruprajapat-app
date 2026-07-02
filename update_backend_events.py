import re

file_path = 'backend/app/api/v1/events.py'
with open(file_path, 'r') as f:
    content = f.read()

# Add r2_service import
if "from app.services import r2_service" not in content:
    content = content.replace("from app.models.user import User", "from app.models.user import User\nfrom app.services import r2_service")

# Add PUT and DELETE endpoints at the end of the file
new_endpoints = """

@router.put("/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: int,
    payload: EventCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    \"\"\"Update an event.\"\"\"
    event = await db.get(Event, event_id)
    if not event or event.is_deleted:
        raise HTTPException(status_code=404, detail="कार्यक्रम नहीं मिला")
        
    if current_user.role not in ["admin", "superadmin"] and event.created_by != current_user.id:
        raise HTTPException(status_code=403, detail="आपको इसे एडिट करने की अनुमति नहीं है")
        
    event.title = payload.title
    event.description = payload.description
    event.event_type = payload.event_type
    event.location = payload.location
    event.start_date = payload.start_date
    event.end_date = payload.end_date
    event.registration_open = payload.registration_open
    event.max_registrations = payload.max_registrations
    
    if payload.cover_image_url and payload.cover_image_url != event.cover_image_url:
        if event.cover_image_url:
            try:
                r2_service.delete_file(event.cover_image_url)
            except Exception:
                pass
        event.cover_image_url = payload.cover_image_url

    await db.commit()
    await db.refresh(event)
    
    return EventResponse(
        id=event.id,
        title=event.title,
        description=event.description,
        event_type=event.event_type,
        location=event.location,
        start_date=event.start_date,
        end_date=event.end_date,
        cover_image_url=event.cover_image_url,
        registration_open=event.registration_open,
        registrations_count=len(event.registrations) if event.registrations else 0,
        created_at=event.created_at,
        community_id=event.community_id,
    )


@router.delete("/{event_id}")
async def delete_event(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    \"\"\"Completely delete an event and its R2 image.\"\"\"
    event = await db.get(Event, event_id)
    if not event:
        raise HTTPException(status_code=404, detail="कार्यक्रम नहीं मिला")
        
    if current_user.role not in ["admin", "superadmin"] and event.created_by != current_user.id:
        raise HTTPException(status_code=403, detail="आपको इसे डिलीट करने की अनुमति नहीं है")
        
    # Completely delete image from R2
    if event.cover_image_url:
        try:
            r2_service.delete_file(event.cover_image_url)
        except Exception as e:
            print(f"Failed to delete R2 file: {e}")
            
    # Hard delete from DB as requested
    await db.delete(event)
    await db.commit()
    
    return {"success": True, "message": "कार्यक्रम पूरी तरह से हटा दिया गया है"}
"""

if "async def delete_event" not in content:
    content += new_endpoints

with open(file_path, 'w') as f:
    f.write(content)
