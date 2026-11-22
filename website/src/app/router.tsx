import { createBrowserRouter } from 'react-router'
import { HomePage } from '../pages/HomePage'
import { NotFoundPage } from '../pages/NotFoundPage'

export const router = createBrowserRouter(
  [
    { path: '/', element: <HomePage /> },
    { path: '*', element: <NotFoundPage /> },
  ],
  { basename: import.meta.env.BASE_URL.replace(/\/$/, '') || '/' },
)
