import snakecaseKeys from 'snakecase-keys'
import { doQuery } from "../../pg-client"
const getUserSettings = async (req: any) => {
  const appUser = (await(doQuery(`select to_jsonb(auth_fn_private.do_get_app_user_info(username, app_tenant_id)) from app.app_user where username = 'appsuperadmin';`))).rows[0].to_jsonb
  const userInfo = JSON.stringify(snakecaseKeys(appUser), null, 2)

  const timezone = req.headers['timezone'] || 'UTC'
  const settings = {
    role: 'app_usr',
    'jwt.claims.app_user_id': appUser.appUserId,
    'jwt.claims.app_tenant_id': appUser.appTenantId,
    'jwt.claims.permission_key': appUser.permissionKey,
    'jwt.claims.permissions': appUser.permissions.join(","),
    'jwt.claims.app_user_ip_address': 'IP NOT IMPLEMENTED',
    'jwt.claims.current_app_user': userInfo,
    timezone: timezone
  }
  req.user = appUser
  return {
    user: appUser,
    settings: settings
  }
}

export default getUserSettings

// // import snakecaseKeys from 'snakecase-keys'
// import parseClaims from './parseClaims'
// import applyImpersonation from '../../applyImpersonation'
// import applyAppTenantScope from '../../applyAppTenantScope'

// const getUserSettings = async (req: any) => {
//   const timezone = req.headers['timezone'] || 'UTC'
//   try {
//     const claims = await parseClaims(req)
//     // console.log('claims', claims)
//     // throw new Error("SESSION EXPIRED")

//     const exp = new Date(claims.exp * 1000)
//     const now = new Date()
//     if (now > exp) {
//       throw new Error("SESSION EXPIRED")
//     } else {
//       const rawUser = applyAppTenantScope(req, applyImpersonation(req, claims[ovbUserClaimKey]))
//       const ovbUser = {
//         ...rawUser
//       }
//     // console.log(now, exp, now > exp, ovbUser.recoveryEmail, timezone)

//       const appRole = (['Support', 'Demo'].indexOf(ovbUser.permissionKey) > -1) ? 'app_adm' : ovbUser.appRole 
//       const appUserIpAddress = req.headers['x-forwarded-for'] || req.connection.remoteAddress || 'unknown';
//       // const userInfo = JSON.stringify(snakecaseKeys(ovbUser), null, 2)
//       const userInfo = ovbUser
//       console.log(userInfo)
//       // if (mode === 'LOCAL') { console.log('userInfo', userInfo.username, appRole) }
//       const settings = {
//         role: appRole,
//         'jwt.claims.app_user_id': ovbUser.appUserId,
//         'jwt.claims.app_tenant_id': ovbUser.appTenantId,
//         'jwt.claims.permission_key': ovbUser.permissionKey,
//         'jwt.claims.permissions': ovbUser.permissions.join(","),
//         'jwt.claims.app_user_ip_address': appUserIpAddress,
//         'jwt.claims.current_app_user': userInfo,
//         timezone: timezone
//       }
//       req.user = ovbUser
//       return {
//         user: ovbUser,
//         settings: settings
//       }
//     }
//   } catch (error: any) {
//     if (error.toString() === 'No token provided') {
//       console.log('ANON')
//       return {
//         user: 'ANON',
//         settings: {
//           timezone: timezone,
//           role: 'app_anon' 
//         } 
//       }
//     } else {
//       console.log('getUserSettings ERROR: ', error)
//       throw error
//     }
//   }
// }

// export default getUserSettings