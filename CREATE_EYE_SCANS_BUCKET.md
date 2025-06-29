# Creating the eye-scans Bucket in Supabase

The error `StorageException(message: Bucket not found, statusCode: 404, error: Bucket not found)` occurs because the "eye-scans" bucket does not exist in your Supabase project. Follow these steps to create it:

## Steps to Create the eye-scans Bucket

1. **Log in to your Supabase Dashboard**
   - Go to [https://app.supabase.com/](https://app.supabase.com/)
   - Sign in with your credentials
   - Select your project

2. **Navigate to Storage**
   - In the left sidebar, click on "Storage"

3. **Create a New Bucket**
   - Click on the "New bucket" button
   - Enter "eye-scans" as the bucket name (must match exactly)
   - Select "Public" for bucket type (or "Private" if you want more security)
   - Click "Create bucket"

4. **Set Up Access Policies**
   - After creating the bucket, click on the "eye-scans" bucket
   - Go to the "Policies" tab
   - Add the following policies:

### For Public Access (if you chose a public bucket)
1. Click "Add policy"
2. Select "For SELECT operations (read)" 
3. Policy name: "Eye scan images are publicly accessible"
4. Policy definition: `bucket_id = 'eye-scans'`
5. Click "Save policy"

### For Authenticated Uploads
1. Click "Add policy"
2. Select "For INSERT operations (create)"
3. Policy name: "Users can upload their own eye scans"
4. Policy definition: 
```sql
bucket_id = 'eye-scans' AND 
auth.role() = 'authenticated' AND 
(storage.foldername(name))[1] = auth.uid()::text
```
5. Click "Save policy"

### For User-Specific Updates
1. Click "Add policy"
2. Select "For UPDATE operations (update)"
3. Policy name: "Users can update their own eye scans"
4. Policy definition:
```sql
bucket_id = 'eye-scans' AND 
auth.uid()::text = (storage.foldername(name))[1]
```
5. Click "Save policy"

### For User-Specific Deletes
1. Click "Add policy"
2. Select "For DELETE operations (delete)"
3. Policy name: "Users can delete their own eye scans"
4. Policy definition:
```sql
bucket_id = 'eye-scans' AND 
auth.uid()::text = (storage.foldername(name))[1]
```
5. Click "Save policy"

## Verify the Setup

After creating the bucket and setting up the policies, try using the eye scan feature again in your app. The error should be resolved, and you should be able to upload and manage eye scans.

## Troubleshooting

If you still encounter issues:

1. Double-check that the bucket name is exactly "eye-scans" (case-sensitive)
2. Ensure that your Supabase client is properly initialized in your app
3. Verify that the user is authenticated when uploading scans
4. Check the Supabase logs for more detailed error information

## Note on Naming Conventions

Supabase bucket names must only contain:
- Lowercase letters (a-z)
- Numbers (0-9)
- Dots (.)
- Hyphens (-)

This is why we're using "eye-scans" instead of "eye_scans" or "eyeScans". 