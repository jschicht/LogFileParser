

;ACE header
$tagACCESS_ALLOWED_ACE 					= "dword Mask;dword SidStart"
$tagACCESS_ALLOWED_CALLBACK_ACE 		= "dword Mask;dword SidStart"
$tagACCESS_ALLOWED_CALLBACK_OBJECT_ACE 	= "dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"
$tagACCESS_ALLOWED_OBJECT_ACE 			= "dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"

$tagACCESS_DENIED_ACE 					= "dword Mask;dword SidStart"
$tagACCESS_DENIED_CALLBACK_ACE 			= "dword Mask;dword SidStart"
$tagACCESS_DENIED_CALLBACK_OBJECT_ACE 	= "dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"
$tagACCESS_DENIED_OBJECT_ACE 			= "dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"

;Unsupported
;SYSTEM_ALARM_ACE
;SYSTEM_ALARM_CALLBACK_ACE
;SYSTEM_ALARM_CALLBACK_OBJECT_ACE
;SYSTEM_ALARM_OBJECT_ACE

$tagSYSTEM_AUDIT_ACE 					= "dword Mask;dword SidStart"
$tagSYSTEM_AUDIT_CALLBACK_ACE 			= "dword Mask;dword SidStart"
$tagSYSTEM_AUDIT_CALLBACK_OBJECT_ACE 	= "dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"
$tagSYSTEM_AUDIT_OBJECT_ACE 			= "dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"

$tagSYSTEM_MANDATORY_LABEL_ACE 			= "dword Mask;dword SidStart"
$tagSYSTEM_RESOURCE_ATTRIBUTE_ACE 		= "dword Mask;dword SidStart"
$tagSYSTEM_SCOPED_POLICY_ID_ACE 		= "dword Mask;dword SidStart"

$tagACL									= "byte AclRevision;byte Sbz1;word AclSize;word AceCount;word Sbz2"
$tagACE_HEADER 							= "byte AceType;byte AceFlags;word AceSize"

;AceType (1 byte): An unsigned 8-bit integer that specifies the ACE types. This field MUST be one of the following values.
Global Const $ACCESS_ALLOWED_ACE_TYPE = 0x00 ;Access-allowed ACE that uses the ACCESS_ALLOWED_ACE (section 2.4.4.2) structure.
Global Const $ACCESS_DENIED_ACE_TYPE = 0x01 ;Access-denied ACE that uses the ACCESS_DENIED_ACE (section 2.4.4.4) structure.
Global Const $SYSTEM_AUDIT_ACE_TYPE = 0x02 ;System-audit ACE that uses the SYSTEM_AUDIT_ACE (section 2.4.4.10) structure.
Global Const $SYSTEM_ALARM_ACE_TYPE = 0x03 ;Reserved for future use.
Global Const $ACCESS_ALLOWED_COMPOUND_ACE_TYPE = 0x04 ;Reserved for future use.
Global Const $ACCESS_ALLOWED_OBJECT_ACE_TYPE = 0x05 ;Object-specific access-allowed ACE that uses the ACCESS_ALLOWED_OBJECT_ACE (section 2.4.4.3) structure.<31>
Global Const $ACCESS_DENIED_OBJECT_ACE_TYPE = 0x06 ;Object-specific access-denied ACE that uses the ACCESS_DENIED_OBJECT_ACE (section 2.4.4.5) structure.<32>
Global Const $SYSTEM_AUDIT_OBJECT_ACE_TYPE = 0x07 ;Object-specific system-audit ACE that uses the SYSTEM_AUDIT_OBJECT_ACE (section 2.4.4.11) structure.<33>
Global Const $SYSTEM_ALARM_OBJECT_ACE_TYPE = 0x08 ;Reserved for future use.
Global Const $ACCESS_ALLOWED_CALLBACK_ACE_TYPE = 0x09 ;Access-allowed callback ACE that uses the ACCESS_ALLOWED_CALLBACK_ACE (section 2.4.4.6) structure.<34>
Global Const $ACCESS_DENIED_CALLBACK_ACE_TYPE = 0x0A ;Access-denied callback ACE that uses the ACCESS_DENIED_CALLBACK_ACE (section 2.4.4.7) structure.<35>
Global Const $ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE = 0x0B ;Object-specific access-allowed callback ACE that uses the ACCESS_ALLOWED_CALLBACK_OBJECT_ACE (section 2.4.4.8) structure.<36>
Global Const $ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE = 0x0C ;Object-specific access-denied callback ACE that uses the ACCESS_DENIED_CALLBACK_OBJECT_ACE (section 2.4.4.9) structure.<37>
Global Const $SYSTEM_AUDIT_CALLBACK_ACE_TYPE = 0x0D ;System-audit callback ACE that uses the SYSTEM_AUDIT_CALLBACK_ACE (section 2.4.4.12) structure.<38>
Global Const $SYSTEM_ALARM_CALLBACK_ACE_TYPE = 0x0E ;Reserved for future use.
Global Const $SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE = 0x0F ;Object-specific system-audit callback ACE that uses the SYSTEM_AUDIT_CALLBACK_OBJECT_ACE (section 2.4.4.14) structure.
Global Const $SYSTEM_ALARM_CALLBACK_OBJECT_ACE_TYPE = 0x10 ;Reserved for future use.
Global Const $SYSTEM_MANDATORY_LABEL_ACE_TYPE = 0x11 ;Mandatory label ACE that uses the SYSTEM_MANDATORY_LABEL_ACE (section 2.4.4.13) structure.
Global Const $SYSTEM_RESOURCE_ATTRIBUTE_ACE_TYPE = 0x12 ;Resource attribute ACE that uses the SYSTEM_RESOURCE_ATTRIBUTE_ACE (section 2.4.4.15)
Global Const $SYSTEM_SCOPED_POLICY_ID_ACE_TYPE = 0x13 ;A central policy ID ACE that uses the SYSTEM_SCOPED_POLICY_ID_ACE (section 2.4.4.16)
Global Const $SYSTEM_PROCESS_TRUST_LABEL_ACE_TYPE = 0x14
;AceFlags (1 byte): An unsigned 8-bit integer that specifies a set of ACE type-specific control flags. This field can be a combination of the following values.
Global Const $CONTAINER_INHERIT_ACE = 0x02 ;Child objects that are containers, such as directories, inherit the ACE as an effective ACE. The inherited ACE is inheritable unless the NO_PROPAGATE_INHERIT_ACE bit flag is also set.
Global Const $FAILED_ACCESS_ACE_FLAG = 0x80 ;Used with system-audit ACEs in a system access control list (SACL) to generate audit messages for failed access attempts.
Global Const $INHERIT_ONLY_ACE = 0x08 ;Indicates an inherit-only ACE, which does not control access to the object to which it is attached. If this flag is not set, the ACE is an effective ACE that controls access to the object to which it is attached. Both effective and inherit-only ACEs can be inherited depending on the state of the other inheritance flags.
Global Const $INHERITED_ACE = 0x10 ;Indicates that the ACE was inherited. The system sets this bit when it propagates an inherited ACE to a child object.<40>
Global Const $NO_PROPAGATE_INHERIT_ACE = 0x04 ;If the ACE is inherited by a child object, the system clears the OBJECT_INHERIT_ACE and CONTAINER_INHERIT_ACE flags in the inherited ACE. This prevents the ACE from being inherited by subsequent generations of objects.
Global Const $OBJECT_INHERIT_ACE = 0x01 ;Noncontainer child objects inherit the ACE as an effective ACE. For child objects that are containers, the ACE is inherited as an inherit-only ACE unless the NO_PROPAGATE_INHERIT_ACE bit flag is also set.
Global Const $SUCCESSFUL_ACCESS_ACE_FLAG = 0x40 ;Used with system-audit ACEs in a SACL to generate audit messages for successful access attempts.
;AceObjectFlags A 32-bit unsigned integer that specifies a set of bit flags that indicate whether the ObjectType and InheritedObjectType fields contain valid data. This parameter can be one or more of the following values.
Global Const $ACE_NO_VALID_OBJECT_TYPE_PRESENT = 0x00000000 ;Neither ObjectType nor InheritedObjectType are valid.
Global Const $ACE_OBJECT_TYPE_PRESENT = 0x00000001 ;ObjectType is valid.
Global Const $ACE_INHERITED_OBJECT_TYPE_PRESENT = 0x00000002 ;InheritedObjectType is valid. If this value is not specified, all types of child objects can inherit the ACE.
;Access masks used with object types
Global Const $ADS_RIGHT_DS_CONTROL_ACCESS = 0x00000100 ;The ObjectType GUID identifies an extended access right.
Global Const $ADS_RIGHT_DS_CREATE_CHILD = 0x00000001 ;The ObjectType GUID identifies a type of child object. The ACE controls the trustee's right to create this type of child object.
Global Const $ADS_RIGHT_DS_READ_PROP = 0x00000010 ;The ObjectType GUID identifies a property set or property of the object. The ACE controls the trustee's right to read the property or property set.
Global Const $ADS_RIGHT_DS_WRITE_PROP = 0x00000020 ;The ObjectType GUID identifies a property set or property of the object. The ACE controls the trustee's right to write the property or property set.
Global Const $ADS_RIGHT_DS_SELF = 0x00000008 ;The ObjectType GUID identifies a validated write.



;AceSize (2 bytes): An unsigned 16-bit integer that specifies the size, in bytes, of the ACE. The AceSize field can be greater than the sum of the individual fields,
;but MUST be a multiple of 4 to ensure alignment on a DWORD boundary. In cases where the AceSize field encompasses additional data for the callback ACEs types,
;that data is implementation-specific. Otherwise, this additional data is not interpreted and MUST be ignored.

;SECURITY_DESCRIPTOR_CONTROL
Global Const $SE_OWNER_DEFAULTED = 0x0001
Global Const $SE_GROUP_DEFAULTED = 0x0002
Global Const $SE_DACL_PRESENT = 0x0004
Global Const $SE_DACL_DEFAULTED = 0x0008
Global Const $SE_SACL_PRESENT = 0x0010
Global Const $SE_SACL_DEFAULTED = 0x0020
Global Const $SE_DACL_UNTRUSTED = 0x0040
Global Const $SE_SERVER_SECURITY = 0x0080
Global Const $SE_DACL_AUTO_INHERIT_REQ = 0x0100
Global Const $SE_SACL_AUTO_INHERIT_REQ = 0x0200
Global Const $SE_DACL_AUTO_INHERITED = 0x0400
Global Const $SE_SACL_AUTO_INHERITED = 0x0800
Global Const $SE_DACL_PROTECTED = 0x1000
Global Const $SE_SACL_PROTECTED = 0x2000
Global Const $SE_RM_CONTROL_VALID = 0x4000
Global Const $SE_SELF_RELATIVE = 0x8000

