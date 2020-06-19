const { origin, hostname } = window.location

const initializeFirebase = async () => {
  await import(`${origin}/__/firebase/7.15.1/firebase-app.js`)
  await import(`${origin}/__/firebase/7.15.1/firebase-auth.js`)
  await import(`${origin}/__/firebase/init.js`)
}

const main = async () => {
  await initializeFirebase()

  const Main = await import('../output/Main')
  if (module.hot) {
    module.hot.accept(() => {
      console.log('Hot reloading.')
      Main.main()
    })
  }

  console.log('Starting…')
  Main.main()
}

main()
