# Backend API Requirements Update

## Overview
Based on code review feedback, the frontend now implements proper data models and parameter validation. The backend needs to ensure these requirements are met.

---

## ✅ Changes Implemented in Frontend

### 1. **Data Models Created**
- `StudentProfile` - For student profile endpoint
- `StudentDashboard` - For dashboard endpoint with subjects
- `AttendanceHistory` - For attendance history endpoint
- `SubjectAttendance` - For subject-specific attendance

### 2. **Parameter Validation Added**
All API methods now validate parameters before sending requests:
- `studentId` must be > 0
- `subjectId` must be > 0
- `startDate` and `endDate` are now **required** (no longer optional)
- `endDate` must be after `startDate`
- Dates cannot be in the future

### 3. **Type Safety Enhanced**
- All numeric values from JSON are properly converted to their expected types
- Attendance percentages handle both `int` and `double` from backend

---

## 🔴 REQUIRED Backend Changes

### 1. **Date Parameters are Now Required**

#### `/api/student/attendance/history/`
**Before (Optional):**
```json
{
  "student_id": 123,
  "start_date": "2026-01-20T00:00:00",  // Optional
  "end_date": "2026-02-19T23:59:59"      // Optional
}
```

**After (Required):**
```json
{
  "student_id": 123,
  "start_date": "2026-01-20T00:00:00",  // ✅ REQUIRED
  "end_date": "2026-02-19T23:59:59"      // ✅ REQUIRED
}
```

**Backend Must:**
- ✅ Mark `start_date` and `end_date` as required fields
- ✅ Validate that `end_date` is after `start_date`
- ✅ Validate that dates are not in the future
- ✅ Return 400 error with clear message if validation fails

---

## ✅ Backend Validation Requirements

### All Student Endpoints Must Validate:

#### 1. **Student ID Validation**
```python
# Pseudo-code example
if student_id is None or student_id <= 0:
    return {
        "detail": "Invalid student ID"
    }, 400

# Verify student exists in database
if not student_exists(student_id):
    return {
        "detail": "Student not found"
    }, 404
```

#### 2. **Subject ID Validation** (for subject attendance endpoint)
```python
if subject_id is None or subject_id <= 0:
    return {
        "detail": "Invalid subject ID"
    }, 400

if not subject_exists(subject_id):
    return {
        "detail": "Subject not found"
    }, 404
```

#### 3. **Date Range Validation** (for attendance history endpoint)
```python
if start_date is None or end_date is None:
    return {
        "detail": "Start date and end date are required"
    }, 400

if end_date < start_date:
    return {
        "detail": "End date must be after start date"
    }, 400

current_time = datetime.now()
if start_date > current_time or end_date > current_time:
    return {
        "detail": "Dates cannot be in the future"
    }, 400
```

---

## 📋 Backend API Checklist

### `/api/student/dashboard/`
- [ ] Validate `student_id` is provided and > 0
- [ ] Verify student exists in database
- [ ] Return proper error messages with 400/404 status codes
- [ ] Ensure `percentage` field in subjects can be returned as int or double (frontend handles both)

### `/api/student/profile/`
- [ ] Validate `student_id` is provided and > 0
- [ ] Verify student exists in database
- [ ] Return proper error messages with 400/404 status codes
- [ ] Ensure `attendance_percentage` can be returned as int or double (frontend handles both)
- [ ] All fields must be present: `email`, `department`, `semester`, `attendance_percentage`, `total_classes`

### `/api/student/attendance/history/`
- [ ] **BREAKING CHANGE**: Make `start_date` and `end_date` required (no longer optional)
- [ ] Validate `student_id` is provided and > 0
- [ ] Validate both dates are provided
- [ ] Validate `end_date` is after `start_date`
- [ ] Validate dates are not in the future
- [ ] Verify student exists in database
- [ ] Return proper error messages with 400/404 status codes
- [ ] Response must include `attendance_records` array

### `/api/student/subject/attendance/`
- [ ] Validate `student_id` is provided and > 0
- [ ] Validate `subject_id` is provided and > 0
- [ ] Verify both student and subject exist in database
- [ ] Verify student is enrolled in the subject
- [ ] Return proper error messages with 400/404 status codes
- [ ] Response must include `attendance_records` array

---

## 🔄 Backward Compatibility

The frontend changes maintain backward compatibility by:
- Still accepting the `data` field in responses (in addition to typed models)
- Gracefully handling missing or null fields with defaults
- Converting both int and double types for percentages

However, the **date requirement change** in attendance history endpoint is a **breaking change** that requires backend update.

---

## 📝 Example Error Responses

Backend should return consistent error responses:

```json
{
  "detail": "Invalid student ID"
}
```

```json
{
  "detail": "Student not found"
}
```

```json
{
  "detail": "Start date and end date are required"
}
```

```json
{
  "detail": "End date must be after start date"
}
```

```json
{
  "detail": "Dates cannot be in the future"
}
```

---

## 🧪 Testing Recommendations

### Test Cases for Backend:

1. **Invalid student_id:**
   - Send `student_id: 0` → Expect 400
   - Send `student_id: -1` → Expect 400
   - Send `student_id: 999999` (non-existent) → Expect 404

2. **Missing required fields:**
   - Omit `start_date` in attendance history → Expect 400
   - Omit `end_date` in attendance history → Expect 400

3. **Invalid date ranges:**
   - Send `end_date` before `start_date` → Expect 400
   - Send dates in the future → Expect 400

4. **Invalid subject_id:**
   - Send `subject_id: 0` → Expect 400
   - Send `subject_id: -1` → Expect 400
   - Send `subject_id: 999999` (non-existent) → Expect 404

5. **Type variations:**
   - Return `attendance_percentage` as int (e.g., 75)
   - Return `attendance_percentage` as double (e.g., 75.5)
   - Frontend should handle both correctly

---

## ⚡ Priority Order

1. **HIGH PRIORITY** - Add validation for all student_id and subject_id parameters
2. **HIGH PRIORITY** - Make dates required in attendance history endpoint
3. **MEDIUM PRIORITY** - Add date range validation
4. **LOW PRIORITY** - Standardize error response format

---

## 📞 Questions?

If you have questions about these requirements or need clarification on any validation logic, please let me know!
