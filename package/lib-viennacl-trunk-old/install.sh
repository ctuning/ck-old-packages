#! /bin/bash

#
# Installation script for ViennaCL.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Anton Lokhmotov, anton@dividiti.com, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

export VIENNACL_SRC_DIR=${INSTALL_DIR}/src
export VIENNACL_OBJ_DIR=${INSTALL_DIR}/obj
export VIENNACL_LIB_DIR=${INSTALL_DIR}/lib
export VIENNACL_PATCH=${PACKAGE_DIR}/181.patch

################################################################################
echo ""
echo "Cloning ViennaCL from '${VIENNACL_URL}' ..."

rm -rf ${VIENNACL_SRC_DIR}

git clone ${VIENNACL_URL} ${VIENNACL_SRC_DIR}

if [ "${?}" != "0" ] ; then
  echo "Error: Cloning ViennaCL from '${VIENNACL_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Configuring ViennaCL..."

rm -rf ${VIENNACL_OBJ_DIR}
mkdir  ${VIENNACL_OBJ_DIR}
cd ${VIENNACL_OBJ_DIR}

cmake ${VIENNACL_SRC_DIR} \
  -DBUILD_TESTING=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
  -DCMAKE_C_COMPILER="${CK_CC_PATH_FOR_CMAKE}" \
  -DCMAKE_CXX_COMPILER="${CK_CXX_PATH_FOR_CMAKE}" \
  -DCMAKE_C_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE}" \
  -DCMAKE_CXX_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE}" \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DENABLE_OPENCL=${CK_INSTALL_ENABLE_OPENCL} \
  -DBOOSTPATH=${CK_ENV_LIB_BOOST}

if [ "$?" != "0" ]; then
  echo "Error: failed configuring ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi

################################################################################
echo ""
echo "Building ViennaCL..."

make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS}

if [ "$?" != "0" ]; then
  echo "Error: failed making ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi

################################################################################
echo ""
echo "Installing ViennaCL..."

make install

# Weirdly, the above command does not copy the library, so doing this manually...
mkdir -p ${VIENNACL_LIB_DIR}
cp -f ${VIENNACL_OBJ_DIR}/libviennacl/libviennacl.so ${VIENNACL_LIB_DIR}

if [ "$?" != "0" ]; then
  echo "Error: failed installing ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi
