import { Router } from "express";
import { z } from "zod";
import { managementClient, openRouter } from "../openrouter.js";

const createKeySchema = z.object({
  name: z.string().min(1),
  limit: z.number().positive().optional(),
  limitReset: z.enum(["daily", "weekly", "monthly"]).optional(),
  includeByokInLimit: z.boolean().optional(),
  expiresAt: z.string().datetime().optional(),
});

const updateKeySchema = z.object({
  name: z.string().min(1).optional(),
  disabled: z.boolean().optional(),
  limit: z.number().positive().optional(),
  limitReset: z.enum(["daily", "weekly", "monthly"]).optional(),
  includeByokInLimit: z.boolean().optional(),
});

export const keysRouter = Router();

keysRouter.get("/keys/me", async (_req, res, next) => {
  try {
    const result = await openRouter.apiKeys.getCurrentKeyMetadata();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

keysRouter.get("/keys", async (_req, res, next) => {
  try {
    const client = managementClient();
    const result = await client.apiKeys.list();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

keysRouter.post("/keys", async (req, res, next) => {
  try {
    const body = createKeySchema.parse(req.body);
    const client = managementClient();
    const result = await client.apiKeys.create({
      requestBody: {
        name: body.name,
        limit: body.limit,
        limitReset: body.limitReset,
        includeByokInLimit: body.includeByokInLimit,
        expiresAt: body.expiresAt ? new Date(body.expiresAt) : undefined,
      },
    });
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
});

keysRouter.get("/keys/:hash", async (req, res, next) => {
  try {
    const client = managementClient();
    const result = await client.apiKeys.get({ hash: req.params.hash });
    res.json(result);
  } catch (error) {
    next(error);
  }
});

keysRouter.patch("/keys/:hash", async (req, res, next) => {
  try {
    const body = updateKeySchema.parse(req.body);
    const client = managementClient();
    const result = await client.apiKeys.update({
      hash: req.params.hash,
      requestBody: body,
    });
    res.json(result);
  } catch (error) {
    next(error);
  }
});

keysRouter.delete("/keys/:hash", async (req, res, next) => {
  try {
    const client = managementClient();
    const result = await client.apiKeys.delete({ hash: req.params.hash });
    res.json(result);
  } catch (error) {
    next(error);
  }
});
