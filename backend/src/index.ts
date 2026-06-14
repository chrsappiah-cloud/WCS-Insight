import cors from "cors";
import express from "express";
import { ZodError } from "zod";
import { config } from "./config.js";
import { chatRouter } from "./routes/chat.js";
import { healthRouter } from "./routes/health.js";
import { keysRouter } from "./routes/keys.js";

const app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.use(healthRouter);
app.use("/api", chatRouter);
app.use("/api", keysRouter);

app.use(
  (
    error: unknown,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction,
  ) => {
    if (error instanceof ZodError) {
      res.status(400).json({
        error: "validation_error",
        details: error.flatten(),
      });
      return;
    }

    const message = error instanceof Error ? error.message : "Unknown error";
    const status = message.includes("OPENROUTER_MANAGEMENT_KEY") ? 503 : 500;

    console.error(error);
    res.status(status).json({
      error: "server_error",
      message,
    });
  },
);

app.listen(config.port, () => {
  console.log(`WCS Insight backend listening on http://localhost:${config.port}`);
});
