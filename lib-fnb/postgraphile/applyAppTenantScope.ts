function applyAppTenantScope(req: any, ovbUser: any): any {
  const scope = req.headers.fnbs

  if (scope) {
    const fnbs = JSON.parse(Buffer.from(scope, 'base64').toString())
    // console.log('fnbs', fnbs, ovbUser.permissionKey)
  if (['SuperAdmin', 'Support', 'Demo'].indexOf(ovbUser.permissionKey) > -1) {
      return {
        ...ovbUser,
        appTenantId: fnbs.id,
        parentAppTenantId: fnbs.parentAppTenantId
      }  
    } else if (['Admin'].indexOf(ovbUser.permissionKey) > -1) {
      return {
        ...ovbUser,
        appTenantId: fnbs.id,
        parentAppTenantId: fnbs.parentAppTenantId
      }  
    } else {
      return ovbUser
    }
  } else {
    return ovbUser
  }
}

export default applyAppTenantScope
