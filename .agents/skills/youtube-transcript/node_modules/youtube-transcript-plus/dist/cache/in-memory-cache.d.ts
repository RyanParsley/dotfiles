import { CacheStrategy } from '../types';
export declare class InMemoryCache implements CacheStrategy {
    private cache;
    private defaultTTL;
    constructor(defaultTTL?: number);
    get(key: string): Promise<string | null>;
    set(key: string, value: string, ttl?: number): Promise<void>;
}
