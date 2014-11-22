/*
    Copyright (c) 2012-2013, BogDan Vatra <bogdan@kde.org>
    Contact: http://www.qt-project.org/legal

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package org.sialan.android;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;

import android.app.Application;
import android.content.Intent;
import android.content.Context;
import android.app.Activity;

public class SialanApplication extends Application
{
    public final static String QtTAG = "Qt";
    public static Object m_delegateObject = null;
    public static HashMap<String, ArrayList<Method>> m_delegateMethods= new HashMap<String, ArrayList<Method>>();
    public static Method dispatchKeyEvent = null;
    public static Method dispatchPopulateAccessibilityEvent = null;
    public static Method dispatchTouchEvent = null;
    public static Method dispatchTrackballEvent = null;
    public static Method onKeyDown = null;
    public static Method onKeyMultiple = null;
    public static Method onKeyUp = null;
    public static Method onTouchEvent = null;
    public static Method onTrackballEvent = null;
    public static Method onActivityResult = null;
    public static Method onCreate = null;
    public static Method onKeyLongPress = null;
    public static Method dispatchKeyShortcutEvent = null;
    public static Method onKeyShortcut = null;
    public static Method dispatchGenericMotionEvent = null;
    public static Method onGenericMotionEvent = null;

    private static Context context;
    private static Application app_instance = null;

    public void onCreate(){
        super.onCreate();
        app_instance = this;
        SialanApplication.context = getApplicationContext();
    }

    public static Context getAppContext() {
        return SialanApplication.context;
    }

    public static Context instance() {
        return app_instance;
    }

    public static void setQtActivityDelegate(Object listener)
    {
        SialanApplication.m_delegateObject = listener;

        ArrayList<Method> delegateMethods = new ArrayList<Method>();
        for (Method m : listener.getClass().getMethods()) {
            if (m.getDeclaringClass().getName().startsWith("org.qtproject.qt5.android"))
                delegateMethods.add(m);
        }

        ArrayList<Field> applicationFields = new ArrayList<Field>();
        for (Field f : SialanApplication.class.getFields()) {
            if (f.getDeclaringClass().getName().equals(SialanApplication.class.getName()))
                applicationFields.add(f);
        }

        for (Method delegateMethod : delegateMethods) {
            try {
                SialanActivity.class.getDeclaredMethod(delegateMethod.getName(), delegateMethod.getParameterTypes());
                if (SialanApplication.m_delegateMethods.containsKey(delegateMethod.getName())) {
                    SialanApplication.m_delegateMethods.get(delegateMethod.getName()).add(delegateMethod);
                } else {
                    ArrayList<Method> delegateSet = new ArrayList<Method>();
                    delegateSet.add(delegateMethod);
                    SialanApplication.m_delegateMethods.put(delegateMethod.getName(), delegateSet);
                }
                for (Field applicationField:applicationFields) {
                    if (applicationField.getName().equals(delegateMethod.getName())) {
                        try {
                            applicationField.set(null, delegateMethod);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            } catch (Exception e) {
            }
        }
    }

    @Override
    public void onTerminate() {
        if (m_delegateObject != null && m_delegateMethods.containsKey("onTerminate"))
            invokeDelegateMethod(m_delegateMethods.get("onTerminate").get(0));
        super.onTerminate();
    }

    public static class InvokeResult
    {
        public boolean invoked = false;
        public Object methodReturns = null;
    }

    private static int stackDeep=-1;
    public static InvokeResult invokeDelegate(Object... args)
    {
        InvokeResult result = new InvokeResult();
        if (m_delegateObject == null)
            return result;
        StackTraceElement[] elements = Thread.currentThread().getStackTrace();
        if (-1 == stackDeep) {
            String activityClassName = SialanActivity.class.getCanonicalName();
            for (int it=0;it<elements.length;it++)
                if (elements[it].getClassName().equals(activityClassName)) {
                    stackDeep = it;
                    break;
                }
        }
        final String methodName=elements[stackDeep].getMethodName();
        if (-1 == stackDeep || !m_delegateMethods.containsKey(methodName))
            return result;

        for (Method m : m_delegateMethods.get(methodName)) {
            if (m.getParameterTypes().length == args.length) {
                result.methodReturns = invokeDelegateMethod(m, args);
                result.invoked = true;
                return result;
            }
        }
        return result;
    }

    public static Object invokeDelegateMethod(Method m, Object... args)
    {
        try {
            return m.invoke(m_delegateObject, args);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
