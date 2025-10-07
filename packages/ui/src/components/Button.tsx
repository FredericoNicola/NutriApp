import React from 'react'

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  children: React.ReactNode
}

export const Button: React.FC<Props> = ({ children, ...rest }) => {
  return (
    <button
      {...rest}
      className={
        'px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 ' +
        (rest.className ?? '')
      }
    >
      {children}
    </button>
  )
}

export default Button
