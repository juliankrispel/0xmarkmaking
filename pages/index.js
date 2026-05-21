import Head from 'next/head'

export default function Home() {
  return (
    <>
      <Head>
        <title>Low-Poly Village — 3D Model Gallery</title>
        <meta name="description" content="Interactive low-poly village game asset models" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <iframe
        src="/village-models.html"
        title="Low-Poly Village 3D Model Gallery"
        style={{
          position: 'fixed',
          inset: 0,
          width: '100%',
          height: '100%',
          border: 'none',
        }}
      />
    </>
  )
}
