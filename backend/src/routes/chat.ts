import { Router } from "express";
import { z } from "zod";
import { config } from "../config.js";
import { openRouter } from "../openrouter.js";

const chatMessageSchema = z.object({
  role: z.enum(["system", "user", "assistant"]),
  content: z.string().min(1),
});

const chatRequestSchema = z.object({
  model: z.string().optional(),
  messages: z.array(chatMessageSchema).min(1),
  temperature: z.number().min(0).max(2).optional(),
  maxTokens: z.number().int().positive().optional(),
});

const reminiscenceRequestSchema = z.object({
  profileName: z.string().min(1),
  sessionTitle: z.string().min(1),
  prompt: z.string().min(1),
  memories: z.array(z.string()).default([]),
  mood: z.string().optional(),
  model: z.string().optional(),
});

export const chatRouter = Router();

chatRouter.post("/chat", async (req, res, next) => {
  try {
    const body = chatRequestSchema.parse(req.body);
    const response = await openRouter.chat.send({
      chatRequest: {
        model: body.model ?? config.defaultModel,
        messages: body.messages,
        temperature: body.temperature,
        maxTokens: body.maxTokens,
        stream: false,
      },
    });

    const content = response.choices[0]?.message?.content ?? "";
    res.json({
      model: response.model,
      content,
      usage: response.usage,
    });
  } catch (error) {
    next(error);
  }
});

chatRouter.post("/reminiscence/prompt", async (req, res, next) => {
  try {
    const body = reminiscenceRequestSchema.parse(req.body);
    const memoryContext = body.memories.length
      ? `Known memories:\n- ${body.memories.join("\n- ")}`
      : "No prior memories were supplied.";

    const response = await openRouter.chat.send({
      chatRequest: {
        model: body.model ?? config.defaultModel,
        messages: [
          {
            role: "system",
            content: [
              "You are a gentle reminiscence facilitator for dementia-care sessions.",
              "Use plain language, short sentences, and warm tone.",
              "Ask one open question at a time and avoid overwhelming detail.",
            ].join(" "),
          },
          {
            role: "user",
            content: [
              `Profile: ${body.profileName}`,
              `Session: ${body.sessionTitle}`,
              body.mood ? `Current mood: ${body.mood}` : "",
              memoryContext,
              `Caregiver request: ${body.prompt}`,
              "Return a short facilitator script with one follow-up question.",
            ]
              .filter(Boolean)
              .join("\n"),
          },
        ],
        temperature: 0.7,
        maxTokens: 400,
        stream: false,
      },
    });

    const content = response.choices[0]?.message?.content ?? "";
    res.json({
      model: response.model,
      script: content,
      usage: response.usage,
    });
  } catch (error) {
    next(error);
  }
});
