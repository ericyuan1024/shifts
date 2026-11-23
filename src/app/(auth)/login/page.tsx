import LoginForm from "./LoginForm";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string }>;
}) {
  const { next } = await searchParams;
  return (
    <main className="page-center">
      <LoginForm next={typeof next === "string" ? next : ""} />
    </main>
  );
}
