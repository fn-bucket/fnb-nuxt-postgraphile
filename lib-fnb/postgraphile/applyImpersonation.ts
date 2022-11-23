function applyImpersonation(req: any, ovbUser: any): any {
  const impersonation = req.headers.fnbi
  if (!impersonation) {
    return {
      ...ovbUser,
      actualAppUserId: ovbUser.appUserId
    }
  } else {
    const impersonatedUser = JSON.parse(Buffer.from(impersonation, 'base64').toString())
    // console.log('=============================================================')
    // console.log('ovbUser', ovbUser)
    // console.log('fnbi', impersonatedUser)
    // console.log('=============================================================')
    if (
      ['SuperAdmin', 'Support', 'Demo'].indexOf(ovbUser.permissionKey) > -1
      || ovbUser.permissions.indexOf('p:super-admin') > -1      
      || ovbUser.permissions.indexOf('p:clinic-patient') > -1    
    ) {
      return {
        ...impersonatedUser,
        actualAppUserId: ovbUser.appUserId
      }
    } else {
      return {
        ...ovbUser,
        actualAppUserId: ovbUser.appUserId
      }
      }
  }
}

export default applyImpersonation
