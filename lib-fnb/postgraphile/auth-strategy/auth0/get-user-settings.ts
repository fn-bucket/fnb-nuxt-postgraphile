// TODO:
// THIS NEEDS TO BE REFACTORED TO REMOVE OVB REFERENCES
// ALSO, IF REMOVING PERMISSION KEY FROM APP USER, FIX THAT TOO

// import snakecaseKeys from 'snakecase-keys'
import parseClaims from './parseClaims'
import applyImpersonation from '../../applyImpersonation'
import applyAppTenantScope from '../../applyAppTenantScope'

const getUserSettings = async (req: any) => {
  const timezone = req.headers['timezone'] || 'UTC'
  try {
    const claims = await parseClaims(req)
    // console.log('claims', claims)
    // throw new Error("SESSION EXPIRED")

    const exp = new Date(claims.exp * 1000)
    const now = new Date()
    if (now > exp) {
      throw new Error("SESSION EXPIRED")
    } else {
      const rawUser = applyAppTenantScope(req, applyImpersonation(req, claims[ovbUserClaimKey]))
      const ovbUser = {
        ...rawUser
      }
    // console.log(now, exp, now > exp, ovbUser.recoveryEmail, timezone)

      const appRole = (['Support', 'Demo'].indexOf(ovbUser.permissionKey) > -1) ? 'app_adm' : ovbUser.appRole 
      const appUserIpAddress = req.headers['x-forwarded-for'] || req.connection.remoteAddress || 'unknown';
      // const userInfo = JSON.stringify(snakecaseKeys(ovbUser), null, 2)
      const userInfo = ovbUser
      console.log(userInfo)
      // if (mode === 'LOCAL') { console.log('userInfo', userInfo.username, appRole) }
      const settings = {
        role: appRole,
        'jwt.claims.app_user_id': ovbUser.appUserId,
        'jwt.claims.app_tenant_id': ovbUser.appTenantId,
        'jwt.claims.permission_key': ovbUser.permissionKey,
        'jwt.claims.permissions': ovbUser.permissions.join(","),
        'jwt.claims.app_user_ip_address': appUserIpAddress,
        'jwt.claims.current_app_user': userInfo,
        timezone: timezone
      }
      req.user = ovbUser
      return {
        user: ovbUser,
        settings: settings
      }
    }
  } catch (error: any) {
    if (error.toString() === 'No token provided') {
      console.log('ANON')
      return {
        user: 'ANON',
        settings: {
          timezone: timezone,
          role: 'app_anon' 
        } 
      }
    } else {
      console.log('getUserSettings ERROR: ', error)
      throw error
    }
  }
}

export default getUserSettings