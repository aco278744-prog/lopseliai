-- ===================================================================
-- MIGRATION: Protect lesson_progress from cross-course manipulation
-- ===================================================================

ALTER TABLE public.lesson_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "progress_select_own" ON public.lesson_progress;
DROP POLICY IF EXISTS "progress_insert_own" ON public.lesson_progress;
DROP POLICY IF EXISTS "progress_update_own" ON public.lesson_progress;
DROP POLICY IF EXISTS "progress_delete_own" ON public.lesson_progress;

CREATE POLICY "progress_select_own"
ON public.lesson_progress
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "progress_insert_own"
ON public.lesson_progress
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id
  AND EXISTS (
    SELECT 1 FROM public.courses
    WHERE courses.id = lesson_progress.course_id
    AND courses.user_id = auth.uid()
  )
);

CREATE POLICY "progress_update_own"
ON public.lesson_progress
FOR UPDATE
TO authenticated
USING (
  auth.uid() = user_id
  AND EXISTS (
    SELECT 1 FROM public.courses
    WHERE courses.id = lesson_progress.course_id
    AND courses.user_id = auth.uid()
  )
)
WITH CHECK (
  auth.uid() = user_id
  AND EXISTS (
    SELECT 1 FROM public.courses
    WHERE courses.id = lesson_progress.course_id
    AND courses.user_id = auth.uid()
  )
);

CREATE POLICY "progress_delete_own"
ON public.lesson_progress
FOR DELETE
TO authenticated
USING (
  auth.uid() = user_id
  AND EXISTS (
    SELECT 1 FROM public.courses
    WHERE courses.id = lesson_progress.course_id
    AND courses.user_id = auth.uid()
  )
);

COMMENT ON TABLE public.lesson_progress IS
  'Tracks lesson completion per user per course. RLS: SELECT/INSERT/UPDATE/DELETE only own progress on own courses.';
