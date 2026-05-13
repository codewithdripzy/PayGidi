import { S3 } from 'aws-sdk';

const addToStorage = async (fileName: string, data: Buffer): Promise<string | null> => {
    const s3 = new S3();

    const params = {
        Bucket: process.env.S3_BUCKET_NAME!,
        Key: fileName,
        Body: data,
    };

    try {
        const result = await s3.upload(params).promise();

        console.log("Successfully uploaded data to " + result.Location);
        return result.Location;
    } catch (err) {
        console.error("Error uploading data: ", err);
        return null;
    }
}


export { addToStorage };