import { defineCollection, z } from 'astro:content';

const innerSpaceCollection = defineCollection({
	type: 'content',
	schema: z.object({
		id: z.string(), // ISJ-001, ISJ-002, ...
		title: z.string(),
		subtitle: z.string().optional(),
		date: z.coerce.date(),
		tags: z.array(z.string()).default([]),
		excerpt: z.string(),
		heroImage: z.string().optional(), // /inner-space/... in /public
		videoUrl: z.string().url().optional(),
		draft: z.boolean().default(false),
	}),
});

export const collections = {
	'inner-space': innerSpaceCollection,
};
