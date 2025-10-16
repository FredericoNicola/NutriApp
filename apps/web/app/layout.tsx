import "../globals.css";

export const metadata = {
  title: "App placeholder scaffold",
  description: "Monorepo demo",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-gray-50 text-slate-900">
        <header className="p-4 border-b bg-white">
          <div className="max-w-4xl mx-auto flex justify-between items-center">
            <div>App placeholder scaffold</div>
            <nav className="space-x-4">
              <a href="/login" className="text-blue-600">
                Login
              </a>
              <a href="/register" className="text-blue-600">
                Register
              </a>
            </nav>
          </div>
        </header>
        <main className="max-w-4xl mx-auto p-4">{children}</main>
      </body>
    </html>
  );
}
