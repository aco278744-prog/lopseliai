ALTER TABLE public.course_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "course_templates_select_public" ON public.course_templates;
DROP POLICY IF EXISTS "course_templates_insert_authenticated" ON public.course_templates;
DROP POLICY IF EXISTS "course_templates_update_authenticated" ON public.course_templates;
DROP POLICY IF EXISTS "course_templates_delete_authenticated" ON public.course_templates;

CREATE POLICY "course_templates_deny_all"
ON public.course_templates
FOR ALL
TO public, authenticated
USING (false)
WITH CHECK (false);

COMMENT ON TABLE public.course_templates IS
  'Cache of pre-generated courses. RLS: Deny all direct access.';
