# Role Management System Documentation

## Overview
This document describes the modular role management system implemented in the attendance app. The system provides type-safe, centralized role management with clear separation of concerns.

## Architecture

### 1. Enums (Type Safety)

#### **UserRole Enum** (`lib/app/core/enums/user_role.dart`)
Defines all user roles in the system with type safety:

```dart
enum UserRole {
  superAdmin('SUPER_ADMIN', 'Super Admin'),
  hod('HOD', 'Head of Department'),
  teacher('TEACHER', 'Teacher');
}
```

**Features:**
- Type-safe role checking
- Automatic string-to-enum conversion
- Role permission checking methods:
  - `isSuperAdmin` - Check if super admin
  - `isHod` - Check if HOD
  - `isTeacher` - Check if teacher
  - `hasAdminPrivileges` - Check if user has admin access (super admin or HOD)
  - `canPerformCrud` - Check if user can create/update/delete (HOD only)
  - `isViewOnly` - Check if user is in view-only mode (super admin)

#### **TeacherType Enum** (`lib/app/core/enums/teacher_type.dart`)
Defines teacher employment types:

```dart
enum TeacherType {
  permanent('PERMANENT', 'Permanent'),
  guest('GUEST', 'Guest'),
  contract('CONTRACT', 'Contract');
}
```

**Features:**
- Type-safe teacher type management
- String-to-enum conversion
- Utility methods for dropdown lists

### 2. UserRoleService (Centralized Role Management)

**Location:** `lib/app/core/services/user_role_service.dart`

**Purpose:** Single source of truth for all role-related operations

**Key Features:**

#### Role Checking
```dart
final roleService = Get.find<UserRoleService>();

// Check current role
if (roleService.isSuperAdmin) { /* ... */ }
if (roleService.isHod) { /* ... */ }
if (roleService.isTeacher) { /* ... */ }
if (roleService.hasAdminPrivileges) { /* ... */ }
```

#### Permission Checking
```dart
// Check specific feature access
if (roleService.canPerformCrud) {
  // Show add/edit/delete buttons
}

if (roleService.isViewOnly) {
  // Hide modification controls
}

// Feature-specific checking
if (roleService.canAccessFeature('add_teacher')) {
  // Show add teacher button
}
```

#### User Information
```dart
// Get user info regardless of role
String name = roleService.userName;         // Works for all roles
String id = roleService.userId;             // Works for all roles
String? deptId = roleService.userDeptId;    // Department ID
String? factId = roleService.userFactId;    // Faculty ID (for super admin)
```

#### UI Helpers
```dart
// Get role-specific greeting
String greeting = roleService.getGreetingMessage();
// Returns: "Welcome\nJohn Doe" (for admin/HOD)
//          "Hi\nJohn Doe" (for teacher)

// Get role display name
String roleName = roleService.getRoleDisplayName();
// Returns: "Super Admin", "Head of Department", or "Teacher"
```

### 3. Updated Models

#### UserModel
```dart
class UserModel {
  final String userId;
  final String userName;
  final String type;
  String? deptId;
  String? factId;
  
  // New: Get role as enum
  UserRole get role => UserRole.fromString(type);
}
```

#### TeacherModel
```dart
class TeacherModel {
  final String teacherId;
  final String teacherName;
  final String type;
  final String deptId;
  
  // New: Get employment type as enum
  TeacherType get employmentType => TeacherType.fromString(type);
}
```

## Usage Examples

### Example 1: Conditional UI Rendering

**Before (Old Way):**
```dart
// Scattered role checking, error-prone
if (Get.find<SignInController>().userData.value.type.toLowerCase() == 'super_admin') {
  // Show something
}
```

**After (New Way):**
```dart
// Clean, type-safe, centralized
final roleService = Get.find<UserRoleService>();

if (roleService.isSuperAdmin) {
  // Show something
}
```

### Example 2: CRUD Button Visibility

**Old Way:**
```dart
// Multiple places checking the same thing differently
if (!Get.find<SignInController>().isSuperAdmin) {
  // Show edit button
}
```

**New Way:**
```dart
// Single, clear permission check
if (Get.find<UserRoleService>().canPerformCrud) {
  // Show edit button
}
```

### Example 3: User Display

**Old Way:**
```dart
// Different code for different roles
if (isSuperAdmin || isHod) {
  name = signInController.userData.value.userName;
} else {
  name = signInController.teacherData.value.teacherName;
}
```

**New Way:**
```dart
// One line, works for all roles
String name = Get.find<UserRoleService>().userName;
```

## Role Permissions Matrix

| Feature | Super Admin | HOD | Teacher |
|---------|-------------|-----|---------|
| View Departments | ✅ | ✅ | ❌ |
| View Programs | ✅ | ✅ | ❌ |
| View Teachers | ✅ | ✅ | ❌ |
| Add Teacher | ❌ | ✅ | ❌ |
| Edit Teacher | ❌ | ✅ | ❌ |
| Delete Teacher | ❌ | ✅ | ❌ |
| View All Departments | ✅ | ❌ | ❌ |
| View All Faculties | ✅ | ❌ | ❌ |
| Mark Attendance | ❌ | ❌ | ✅ |
| View Own Courses | ❌ | ❌ | ✅ |

## Implementation Checklist

### ✅ Completed
1. Created `UserRole` enum for type-safe role management
2. Created `TeacherType` enum for teacher employment types
3. Implemented `UserRoleService` as centralized role manager
4. Updated `UserModel` with role enum getter
5. Updated `TeacherModel` with employment type enum getter
6. Integrated `UserRoleService` into dependency injection
7. Updated HOD dashboard to use `UserRoleService`
8. Updated Teacher dashboard to use `UserRoleService`
9. Updated ManageTeachers view to use `UserRoleService`
10. Updated TeacherCard widget to use `UserRoleService`
11. Updated teacher type controllers to use `TeacherType` enum
12. Added comprehensive documentation

## Benefits

### 1. **Type Safety**
- Compile-time error checking
- No more typos in role strings
- IDE autocompletion support

### 2. **Maintainability**
- Single source of truth for roles
- Easy to add new roles or permissions
- Clear separation of concerns

### 3. **Readability**
```dart
// Very clear intent
if (roleService.canPerformCrud) { }

// vs unclear string comparison
if (user.type != 'SUPER_ADMIN' && user.type == 'HOD') { }
```

### 4. **Testability**
- Easy to mock `UserRoleService`
- Clear permission boundaries
- Simple unit tests

### 5. **Scalability**
- Easy to add new roles
- Easy to add new permissions
- Feature flags integrated with roles

## Migration Guide

### For Existing Code

**Step 1:** Replace direct SignInController access
```dart
// Old
if (Get.find<SignInController>().isSuperAdmin) { }

// New
if (Get.find<UserRoleService>().isSuperAdmin) { }
```

**Step 2:** Use centralized user info
```dart
// Old
final name = isHod 
    ? signInController.userData.value.userName
    : signInController.teacherData.value.teacherName;

// New
final name = Get.find<UserRoleService>().userName;
```

**Step 3:** Use permission checks instead of role checks
```dart
// Old
if (!isSuperAdmin && isHod) { // Show CRUD buttons }

// New
if (Get.find<UserRoleService>().canPerformCrud) { // Show CRUD buttons }
```

## Future Enhancements

1. **Role-based routing guards**
   - Automatic route protection based on roles
   
2. **Audit logging**
   - Track who performed which actions
   
3. **Dynamic permissions**
   - Load permissions from backend
   
4. **Role hierarchies**
   - More complex permission inheritance

## Conclusion

The new role management system provides:
- ✅ Type safety with enums
- ✅ Centralized role management
- ✅ Clear permission boundaries
- ✅ Better code readability
- ✅ Easier maintenance
- ✅ Scalable architecture

All role-related code is now modular, maintainable, and easy to understand!
