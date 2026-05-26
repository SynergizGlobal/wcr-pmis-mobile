enum UserRole {
  superUser('Super User'),
  regularUser('Regular User'),
  contractor('Contractor'),
  contractorRep('Contractor Rep'),
  engineer('Engineer'),
  hod('HOD'),
  dyHod('Data Admin'),
  dyHodEngineer('Data Admin (Engineer)'),
  itAdmin('IT Admin'),
  unknown('');

  final String roleName;
  const UserRole(this.roleName);

  static UserRole fromLoginResponse(Map<String, dynamic> response) {
    final userType = response['userTypeFk']?.toString();
    final roleName = response['userRoleNameFk']?.toString();

    if (roleName == 'Data Admin') {
      if (userType == 'Officer (Jr./Sr. Scale)') {
        return UserRole.dyHodEngineer;
      }
      return UserRole.dyHod;
    }

    if (roleName == 'IT Admin') {
      return UserRole.itAdmin;
    }

    if (roleName == 'Super User') {
      return UserRole.superUser;
    }

    if (userType == 'Contractor') {
      return UserRole.contractor;
    }

    if (userType == 'Contractor Rep') {
      return UserRole.contractorRep;
    }

    if (userType == 'Officer (Jr./Sr. Scale)') {
      return UserRole.engineer;
    }

    if (userType == 'HOD') {
      return UserRole.hod;
    }

    return UserRole.unknown;
  }
}

extension UserRolePermissions on UserRole {
  
  bool get canCreateRfi => this == UserRole.contractor || this == UserRole.itAdmin;

  bool canEditRfi(String status) {
    if (this != UserRole.contractor) return false;
    final s = status.trim().toUpperCase();
    return s == 'CREATED' ||
        s == 'OPEN' ||
        s == 'UPDATED' ||
        s == 'RESCHEDULED' ||
        s == 'REASSIGNED';
  }

  bool canDeleteRfi(String status) {
    if (this == UserRole.itAdmin) return true;
    if (this != UserRole.contractor) return false;
    final s = status.trim().toUpperCase();
    return s == 'CREATED' ||
        s == 'OPEN' ||
        s == 'UPDATED' ||
        s == 'RESCHEDULED' ||
        s == 'REASSIGNED';
  }

  bool canStartInspection(String status) {
    final s = status.toUpperCase();
    if (this == UserRole.contractorRep) {
      if (s == 'CREATED' ||
          s == 'UPDATED' ||
          s == 'RESCHEDULED' ||
          s == 'REASSIGNED' ||
          s == 'CON_INSP_ONGOING' ||
          s == 'UNDER_CON_RECTIFICATION') {
        return true;
      }
    } else if (this == UserRole.engineer || this == UserRole.dyHodEngineer) {
      if (s == 'INSPECTED_BY_CON' ||
          s == 'AE_INSP_ONGOING' ||
          s == 'UNDER_ENGG_RECTIFICATION') {
        return true;
      }
    }
    return false;
  }

  bool canSubmitInspection(String status) {
    final s = status.toUpperCase();
    if (this == UserRole.contractorRep) {
      return s == 'CREATED' ||
          s == 'UPDATED' ||
          s == 'RESCHEDULED' ||
          s == 'REASSIGNED' ||
          s == 'CON_INSP_ONGOING' ||
          s == 'UNDER_CON_RECTIFICATION';
    } else if (this == UserRole.engineer || this == UserRole.dyHodEngineer) {
      return s == 'INSPECTED_BY_CON' ||
          s == 'AE_INSP_ONGOING' ||
          s == 'INSPECTED_BY_AE' ||
          s == 'UNDER_ENGG_RECTIFICATION';
    }
    return false;
  }

  bool canUploadAttachments(String status) {
    final s = status.toUpperCase();
    if (this == UserRole.contractorRep) {
      return s == 'INSPECTED_BY_CON' ||
          s == 'AE_INSP_ONGOING' ||
          s == 'INSPECTED_BY_AE' ||
          s == 'UNDER_CON_RECTIFICATION' ||
          s == 'VALIDATION_PENDING' ||
          s == 'VALIDATION PENDING' ||
          s == 'INSPECTION_DONE' ||
          s == 'INSPECTION DONE';
    }
    if (this != UserRole.engineer && this != UserRole.dyHodEngineer) {
      return false;
    }
    return s == 'AE_INSP_ONGOING' ||
        s == 'INSPECTED_BY_AE' ||
        s == 'UNDER_ENGG_RECTIFICATION' ||
        s == 'VALIDATION_PENDING' ||
        s == 'VALIDATION PENDING' ||
        s == 'INSPECTION_DONE' ||
        s == 'INSPECTION DONE';
  }

  bool canUploadTestResults(String status) {
    final s = status.toUpperCase();
    if (this == UserRole.contractorRep) {
      return s == 'INSPECTED_BY_CON' ||
          s == 'AE_INSP_ONGOING' ||
          s == 'INSPECTED_BY_AE' ||
          s == 'UNDER_CON_RECTIFICATION' ||
          s == 'VALIDATION_PENDING' ||
          s == 'VALIDATION PENDING' ||
          s == 'INSPECTION_DONE' ||
          s == 'INSPECTION DONE';
    }
    if (this != UserRole.engineer && this != UserRole.dyHodEngineer) {
      return false;
    }
    return s == 'AE_INSP_ONGOING' ||
        s == 'INSPECTED_BY_AE' ||
        s == 'UNDER_ENGG_RECTIFICATION' ||
        s == 'VALIDATION_PENDING' ||
        s == 'VALIDATION PENDING' ||
        s == 'INSPECTION_DONE' ||
        s == 'INSPECTION DONE';
  }

  bool canSendForValidation(String status) {
    final s = status.toUpperCase();
    if ((this == UserRole.engineer || this == UserRole.dyHodEngineer) &&
        (s == 'INSPECTED_BY_AE' || s == 'INSPECTION BY AE')) {
      return true;
    }
    return false;
  }

  bool canApprove(String status) {
    final s = status.toUpperCase();
    if ((this == UserRole.dyHod || this == UserRole.dyHodEngineer) &&
        (s == 'VALIDATION_PENDING' || s == 'VALIDATION PENDING')) {
      return true;
    }
    return false;
  }

  bool canRejectOrClose(String status) {
    final s = status.toUpperCase();
    if ((this == UserRole.dyHod || this == UserRole.dyHodEngineer || this == UserRole.hod) &&
        (s == 'VALIDATION_PENDING' || s == 'VALIDATION PENDING')) {
      return true;
    } else if ((this == UserRole.engineer || this == UserRole.dyHodEngineer) &&
        (s == 'INSPECTED_BY_AE' ||
            s == 'INSPECTION BY AE' ||
            s == 'VALIDATION_PENDING' ||
            s == 'VALIDATION PENDING')) {
      return true;
    }
    return false;
  }


  bool canViewRfi(String status) {
    return true;
  }

  bool get canViewUpdatedRfi =>
      this == UserRole.contractor || this == UserRole.itAdmin;

  bool get canViewScheduledRfi => this != UserRole.unknown;

  bool get canViewRescheduledRfi => this != UserRole.unknown;

  bool get canViewInspection =>
      this == UserRole.hod ||
      this == UserRole.engineer ||
      this == UserRole.contractor ||
      this == UserRole.contractorRep ||
      this == UserRole.dyHod ||
      this == UserRole.dyHodEngineer ||
      this == UserRole.itAdmin;

  bool get canViewRfiLog =>
      this != UserRole.unknown;

  bool get canViewValidation =>
      this == UserRole.hod ||
      this == UserRole.engineer ||
      this == UserRole.dyHod ||
      this == UserRole.dyHodEngineer ||
      this == UserRole.itAdmin;

  bool get canEditValidation =>
      this == UserRole.hod ||
      this == UserRole.dyHod ||
      this == UserRole.dyHodEngineer ||
      this == UserRole.itAdmin;

  bool canChangeExecutive(String status) {
    final s = status.toUpperCase();
    if (this == UserRole.engineer ||
        this == UserRole.dyHodEngineer ||
        this == UserRole.hod ||
        this == UserRole.dyHod ||
        this == UserRole.itAdmin) {
      return s == '' ||
          s == 'CREATED' ||
          s == 'UPDATED' ||
          s == 'RESCHEDULED' ||
          s == 'REASSIGNED' ||
          s == 'CON_INSP_ONGOING' ||
          s == 'INSPECTED_BY_CON';
    }
    return false;
  }

  bool get canViewInspectionReferenceForm => this == UserRole.itAdmin;
}
