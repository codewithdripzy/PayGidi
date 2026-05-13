import { v2 as cloudinary } from 'cloudinary';

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

const uploadToCloudinary = async (fileBuffer: Buffer, fileName: string, folder: string = 'knowledge-base'): Promise<string | null> => {
    return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
            {
                folder,
                resource_type: 'auto',
                public_id: fileName.replace(/\.[^/.]+$/, ''),
            },
            (error: any, result: any) => {
                if (error) {
                    console.error('Cloudinary upload error:', error);
                    reject(null);
                } else {
                    console.log('Successfully uploaded to Cloudinary:', result?.secure_url);
                    resolve(result?.secure_url || null);
                }
            }
        );

        uploadStream.end(fileBuffer);
    });
};

export { uploadToCloudinary };
