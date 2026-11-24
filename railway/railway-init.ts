// First-boot setup for the Railway template: creates the administrator from
// DOCA_ADMIN_LOGIN / DOCA_ADMIN_PASSWORD (there is no default account and no setup
// wizard), and switches the site's default language to English and time zone to UTC.
// Runs before the server starts; does nothing once an administrator exists.
import { createUser } from "@core/modules/identity/passwords.js";
import { openDatabase } from "@db/index.js";
import { config } from "./config.js";

const db = await openDatabase(config().database);
try {
  const existing = await db
    .selectFrom("users")
    .select("id")
    .where("admin", "=", 1)
    .executeTakeFirst();
  if (existing) {
    process.stdout.write("[railway] administrator already exists, nothing to do\n");
  } else {
    const login = (process.env.DOCA_ADMIN_LOGIN ?? "").trim().toLowerCase() || "admin";
    const password = process.env.DOCA_ADMIN_PASSWORD ?? "";
    if (password.length < 12 || password.length > 128)
      throw new Error("DOCA_ADMIN_PASSWORD must be 12 to 128 characters long");
    await createUser(db, { login, password, displayName: "Administrator" }, { bootstrap: true });
    const settings = await db
      .selectFrom("settings")
      .select("revision")
      .where("id", "=", "system")
      .executeTakeFirstOrThrow();
    await db
      .updateTable("settings")
      .set({
        default_locale: process.env.DOCA_DEFAULT_LOCALE === "zh" ? "zh" : "en",
        default_timezone: process.env.DOCA_DEFAULT_TIMEZONE?.trim() || "UTC",
        revision: settings.revision + 1,
      })
      .where("id", "=", "system")
      .execute();
    process.stdout.write(`[railway] created administrator "${login}"\n`);
  }
} finally {
  await db.destroy();
}
