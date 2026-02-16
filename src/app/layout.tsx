import type { Metadata } from "next";
import { Space_Grotesk, Space_Mono } from "next/font/google";
import "./globals.css";

const spaceGrotesk = Space_Grotesk({
  variable: "--font-primary",
  subsets: ["latin"],
});

const spaceMono = Space_Mono({
  variable: "--font-mono",
  subsets: ["latin"],
  weight: ["400", "700"],
});

export const metadata: Metadata = {
  title: "Scheduling MVP",
  description: "Mobile-first scheduling for small teams",
};

const buildInfo = process.env.BUILD_TIMESTAMP ?? "unknown";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body
        className={`${spaceGrotesk.variable} ${spaceMono.variable} antialiased`}
      >
        <div className="app-shell">
          {children}
          <footer className="app-footer">
            <div>opt by Kongfu Cat Ramen Bar</div>
            <div className="app-footer-sub">build info: {buildInfo}</div>
          </footer>
        </div>
      </body>
    </html>
  );
}
