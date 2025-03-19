import { Context } from "https://edge.netlify.com";

export default async (request: Request, context: Context) => {
  const response = await context.next();
  const url = new URL(request.url);
  
  if (!url.pathname.includes('.')) {
    return new Response(response.body, {
      ...response,
      headers: {
        ...response.headers,
        'Content-Type': 'text/html',
      },
    });
  }
  
  return response;
}; 