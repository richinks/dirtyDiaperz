import fs from "fs";

export async function post({ request }) {
  const data = await request.formData();
  const file = data.get("file");

  const buffer = Buffer.from(await file.arrayBuffer());
  fs.writeFileSync(`incoming/${file.name}`, buffer);

  return {
    status: 200,
    body: { message: "Song uploaded — automation triggered!" }
  };
}
