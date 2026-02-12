import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL as string | undefined;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY as string | undefined;

export function getSupabaseClient() {
	if (!supabaseUrl || !supabaseAnonKey) {
		throw new Error(
			'Missing PUBLIC_SUPABASE_URL / PUBLIC_SUPABASE_ANON_KEY. Add them to your Cloudflare Pages project environment variables and local .env.'
		);
	}

	return createClient(supabaseUrl, supabaseAnonKey);
}
