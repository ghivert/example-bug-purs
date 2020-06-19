exports.foreignAuthStateChanged = callback => () => {
  return firebase.auth().onAuthStateChanged(callback)
}

const selectProvider = provider => {
  switch (provider) {
    case 'Google':
      return new firebase.auth.GoogleAuthProvider()
  }
}

exports.foreignSignInWithPopup = provider => scopes => () => {
  const authProvider = selectProvider(provider)
  scopes.forEach(scope => authProvider.addScope(scope))
  return firebase.auth().signInWithPopup(authProvider)
}

exports.foreignSignOut = () => {
  return firebase.auth().signOut()
}
