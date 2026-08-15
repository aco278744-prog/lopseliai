-- ===================================================================
-- MIGRATION: Lock course system fields (status, content, error_message)
-- ===================================================================

ALTER TABLE public.courses DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "courses_select_own" ON public.courses;
DROP POLICY IF EXISTS "courses_insert_own" ON public.courses;
DROP POLICY IF EXISTS "courses_update_own" ON public.courses;
DROP POLICY IF EXISTS "courses_delete_own" ON public.courses;
DROP POLICY IF EXISTS "courses_update_own_restricted" ON public.courses;

CREATE POLICY "courses_select_own"
ON public.courses
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "courses_insert_own"
ON public.courses
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "courses_update_own"
ON public.courses
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "courses_delete_own"
ON public.courses
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.prevent_course_tampering()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status THEN
    RAISE EXCEPTION
      'Access denied: cannot modify course status via client SDK.';
  END IF;

  IF NEW.content IS DISTINCT FROM OLD.content THEN
    RAISE EXCEPTION
      'Access denied: cannot modify course content via client SDK.';
  END IF;

  IF NEW.error_message IS DISTINCT FROM OLD.error_message THEN
    RAISE EXCEPTION
      'Access denied: cannot modify error_message via client SDK.';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS courses_prevent_tampering ON public.courses;
CREATE TRIGGER courses_prevent_tampering
BEFORE UPDATE ON public.courses
FOR EACH ROW
WHEN (current_user != 'postgres' AND current_user != 'service_role')
EXECUTE FUNCTION public.prevent_course_tampering();

COMMENT ON TABLE public.courses IS
  'User courses and generation state. Protected by trigger against client tampering.';
